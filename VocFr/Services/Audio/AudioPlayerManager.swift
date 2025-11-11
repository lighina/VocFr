import Foundation
import AVFoundation
import Combine

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
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("音频会话设置失败: \(error)")
        }
    }
    
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
