import Foundation
import AVFoundation
import Combine
import SwiftData

class AudioPlayerManager: NSObject, ObservableObject {
    static let shared = AudioPlayerManager()

    @Published var isPlaying: Bool = false

    private var audioPlayer: AVAudioPlayer?
    private var completionHandler: ((Bool) -> Void)?
    private var playbackTimer: Timer?
    private var segmentEndTime: Double?

    private override init() {
        super.init()
        setupAudioSession()
    }

    private func setupAudioSession() {
        #if os(iOS)
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("音频会话设置失败: \(error)")
        }
        #elseif os(macOS)
        // AVAudioSession is not available on macOS
        // Audio will work without explicit session setup on macOS
        print("ℹ️ Audio session setup skipped on macOS (not required)")
        #endif
    }

    // MARK: - Filename Normalization

    /// Normalize French text to create valid filenames.
    /// Converts accented characters to ASCII equivalents and replaces spaces with hyphens.
    /// This matches the Python script's normalization logic.
    ///
    /// Examples:
    /// - "éponge" -> "eponge"
    /// - "fenêtre" -> "fenetre"
    /// - "salle de classe" -> "salle-de-classe"
    private func normalizeFilename(_ text: String) -> String {
        // Remove diacritics (accents) to get ASCII equivalents
        let normalized = text.folding(options: .diacriticInsensitive, locale: .current)

        // Convert to lowercase
        let lowercased = normalized.lowercased()

        // Replace spaces with hyphens
        let spacesReplaced = lowercased.replacingOccurrences(of: " ", with: "-")

        // Remove any remaining special characters (keep only letters, numbers, hyphens)
        let cleaned = spacesReplaced.components(separatedBy: CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-")).inverted).joined()

        return cleaned
    }

    // MARK: - Word Audio Playback (Phase 2.6)

    /// Find and play audio for a word, trying multiple strategies:
    /// 1. Try independent audio file (Phase 2.6): Unite{N}/Section{M}/{normalized_name}.mp3
    /// 2. Try audio segments with timestamps (Phase 2.0-2.5): audioWithTimestamps.m4a
    /// 3. Fallback: Try root-level audio files
    ///
    /// - Parameters:
    ///   - word: The word to play audio for
    ///   - section: Optional section context (important for words that appear in multiple sections)
    ///   - completion: Callback with success/failure status
    func playWordAudio(for word: Word, in section: Section? = nil, completion: @escaping (Bool) -> Void) {
        print("🎵 Playing audio for word: '\(word.canonical)'")

        // Strategy 1: Try independent audio files (Phase 2.6)
        if let audioPath = findIndependentAudioFile(for: word, in: section) {
            print("  ✅ Found independent audio: \(audioPath)")
            playAudio(filename: audioPath, completion: completion)
            return
        }

        // Strategy 2: Try audio segments with timestamps (backward compatibility)
        if let audioSegment = word.audioSegments.first,
           let audioFile = audioSegment.audioFile {
            print("  ✅ Using timestamp-based audio: \(audioFile.fileName) (\(audioSegment.startTime)s-\(audioSegment.endTime)s)")
            playAudioSegment(
                filename: audioFile.fileName,
                startTime: audioSegment.startTime,
                endTime: audioSegment.endTime,
                completion: completion
            )
            return
        }

        // Strategy 3: No audio found
        print("  ❌ No audio found for word: '\(word.canonical)'")
        completion(false)
    }

    /// Find independent audio file for a word using normalized filename.
    /// Searches multiple locations with different naming strategies:
    /// 1. Flat structure with prefix: u{N}s{M}-{word}.mp3 (for Xcode flat bundle)
    /// 2. Directory structure: Audio/Words/Unite{N}/Section{M}/{word}.mp3 (for folder references)
    /// 3. Root level fallback: {word}.mp3
    ///
    /// - Parameters:
    ///   - word: The word to find audio for
    ///   - section: Optional section context (if provided, uses this instead of word's first section)
    private func findIndependentAudioFile(for word: Word, in section: Section?) -> String? {
        let normalizedName = normalizeFilename(word.canonical)

        // Use provided section or fall back to word's first section
        let targetSection = section ?? word.sectionWords.first?.section

        // Try to get unite and section numbers from section
        if let targetSection = targetSection,
           let unite = targetSection.unite {
            let uniteNumber = unite.number
            let sectionIndex = targetSection.orderIndex

            print("  🔍 Searching for: Unite \(uniteNumber), Section \(sectionIndex), word '\(normalizedName)'")

            // Search paths (in order of preference):
            let searchPaths = [
                // Strategy 1: Flat structure with prefix (Xcode 16 flat bundle)
                // Format: u{N}s{M}-{word}.mp3 (e.g., u1s1-bureau.mp3, u2s4-aimer.mp3)
                "u\(uniteNumber)s\(sectionIndex)-\(normalizedName)",

                // Strategy 2: Directory structure (if folder references work)
                // Format: Audio/Words/Unite{N}/Section{M}/{word}.mp3
                "Audio/Words/Unite\(uniteNumber)/Section\(sectionIndex)/\(normalizedName)",

                // Strategy 3: Legacy directory structure
                "Audio/\(normalizedName)",

                // Strategy 4: Root level (backward compatibility)
                normalizedName
            ]

            for path in searchPaths {
                print("  🔍 Trying path: \(path)")
                if let url = resolveURL(for: path) {
                    print("  ✅ Found audio at: \(path) → \(url.lastPathComponent)")
                    return path
                }
            }

            print("  ❌ No audio found in any search path")
        }

        // Final fallback: try normalized name directly
        if resolveURL(for: normalizedName) != nil {
            return normalizedName
        }

        return nil
    }

    // MARK: - Basic Audio Playback

    func playAudio(filename: String, completion: @escaping (Bool) -> Void) {
        completionHandler = completion
        
        guard let url = resolveURL(for: filename) else {
            print("找不到音频文件: \(filename)")
            completion(false)
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            print("🎧 播放完整音频文件: \(url.lastPathComponent)")
            
            let success = audioPlayer?.play() ?? false
            if success {
                isPlaying = true
            } else {
                completion(false)
            }
        } catch {
            print("音频播放失败: \(error)")
            completion(false)
        }
    }
    
    func playAudioSegment(filename: String, startTime: Double, endTime: Double, completion: @escaping (Bool) -> Void) {
        completionHandler = completion
        
        guard let url = resolveURL(for: filename) else {
            print("找不到音频文件: \(filename)")
            completion(false)
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            print("🎧 播放音频片段: \(url.lastPathComponent) (\(startTime)s - \(endTime)s)")
            
            // Set the current time to start time
            audioPlayer?.currentTime = startTime
            segmentEndTime = endTime
            
            let success = audioPlayer?.play() ?? false
            if success {
                isPlaying = true
                print("播放音频片段: \(filename) (\(startTime)s - \(endTime)s)")
                
                // Set up timer to stop at end time
                let duration = endTime - startTime
                playbackTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
                    self?.stopAudio()
                }
            } else {
                completion(false)
            }
        } catch {
            print("音频播放失败: \(error)")
            completion(false)
        }
    }
    
    // MARK: - Resource Resolution Helpers
    private let supportedExtensions: [String] = ["wav", "mp3", "m4a", "aac"]

    private func resolveURL(for filename: String) -> URL? {
        // Normalize name and optional extension
        let fileURL = URL(fileURLWithPath: filename)
        let baseName = fileURL.deletingPathExtension().lastPathComponent
        let providedExt = fileURL.pathExtension

        // If caller provided an extension, try it first
        if !providedExt.isEmpty {
            if let url = Bundle.main.url(forResource: baseName, withExtension: providedExt) {
                return url
            }
        }

        // Otherwise, try common audio extensions
        for ext in supportedExtensions {
            if let url = Bundle.main.url(forResource: baseName, withExtension: ext) {
                return url
            }
        }
        return nil
    }
    
    func stopAudio() {
        playbackTimer?.invalidate()
        playbackTimer = nil
        segmentEndTime = nil
        
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
        completionHandler?(true)
        completionHandler = nil
    }
    
    func togglePlayback(filename: String, startTime: Double? = nil, endTime: Double? = nil, completion: @escaping (Bool) -> Void) {
        if isPlaying {
            stopAudio()
            completion(true)
        } else {
            if let start = startTime, let end = endTime {
                playAudioSegment(filename: filename, startTime: start, endTime: end, completion: completion)
            } else {
                playAudio(filename: filename, completion: completion)
            }
        }
    }
}


extension AudioPlayerManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playbackTimer?.invalidate()
        playbackTimer = nil
        segmentEndTime = nil
        
        isPlaying = false
        completionHandler?(flag)
        completionHandler = nil
        audioPlayer = nil
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("音频解码错误: \(error?.localizedDescription ?? "未知错误")")
        
        playbackTimer?.invalidate()
        playbackTimer = nil
        segmentEndTime = nil
        
        isPlaying = false
        completionHandler?(false)
        completionHandler = nil
        audioPlayer = nil
    }
}
