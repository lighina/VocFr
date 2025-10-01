import SwiftUI
import SwiftData
import AVFoundation

// Extension for custom corner radius
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// 新的单词详情页面
struct WordDetailViewFixed: View {
    let word: Word
    @ObservedObject private var audioManager = AudioPlayerManager.shared
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color(.systemGray6), Color(.systemGray5)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 40) {
                    Spacer(minLength: 60)
                    
                    // 单词图片 - 居中显示
                    wordImageCentered
                    
                    // 单词信息卡片 - 匹配设计样式
                    VStack(spacing: 20) {
                        // 主单词
                        Text(word.canonical)
                            .font(.system(size: 36, weight: .medium))
                            .foregroundColor(.black)
                        
                        // 词性信息 - 斜体小字
                        Text(getPartOfSpeechText())
                            .font(.system(size: 14, weight: .regular))
                            .italic()
                            .foregroundColor(.secondary)
                        
                        // 中文翻译 - Content Area 样式
                        Text(word.chinese)
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 10)
                        
                        // 蓝色圆形播放按钮
                        Button(action: playAudio) {
                            Image(systemName: audioManager.isPlaying ? "stop.fill" : "play.fill")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                                .background(Color.blue)
                                .clipShape(Circle())
                        }
                        .animation(.easeInOut(duration: 0.2), value: audioManager.isPlaying)
                    }
                    .padding(.top, 32)
                    .padding(.bottom, 40)
                    .padding(.horizontal, 24)
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(24)
                    .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
                    .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)
                    
                    Spacer(minLength: 60)
                }
                .padding(.horizontal, 20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Toggle("", isOn: .constant(true))
                    .toggleStyle(SwitchToggleStyle(tint: .green))
            }
        }
    }
    
    @ViewBuilder
    private var wordImageCentered: some View {
        if !word.imageName.isEmpty {
            Image(word.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 220)
                .onAppear {
                    print("✅ 尝试从Assets加载图片: \(word.imageName)")
                }
        } else {
            Image(systemName: "photo.badge.plus")
                .font(.system(size: 80))
                .foregroundColor(.gray)
                .frame(height: 220)
        }
    }
    
    private func getPartOfSpeechText() -> String {
        switch word.partOfSpeech {
        case .noun:
            // 检查是否有定冠词形式来判断性别
            if let definiteForm = word.forms.first(where: { $0.formType == .definiteArticle }) {
                if definiteForm.french.lowercased().hasPrefix("le ") {
                    return "nom (m.)"
                } else if definiteForm.french.lowercased().hasPrefix("la ") {
                    return "nom (f.)"
                } else if definiteForm.french.lowercased().hasPrefix("les ") {
                    return "nom (pl.)"
                }
            }
            return "nom"
        case .verb:
            return "verbe"
        case .adjective:
            return "adjective"
        case .number:
            return "number"
        case .preposition:
            return "préposition"
        case .pronoun:
            return "pronoun"
        case .other:
            return "autre"
        }
    }

    
    private func debugImageSearch(for word: Word) {
        print("🔍 调试图片搜索: \(word.canonical)")
        print("📝 存储的图片名: \(word.imageName)")
        
        // Check Assets first
        print("\n📦 检查Assets中的图片:")
        let assetsNames = [
            word.imageName,
            "\(word.canonical)_image",
            word.canonical
        ]
        
        for name in assetsNames {
            print("  🔍 尝试Assets: \(name)")
            print("    💡 使用 Image(\"\(name)\") 从Assets加载")
        }
        
        // Then check Bundle files
        print("\n📁 检查Bundle中的文件:")
        if let bundlePath = Bundle.main.resourcePath {
            do {
                let contents = try FileManager.default.contentsOfDirectory(atPath: bundlePath)
                let imageFiles = contents.filter { file in
                    let ext = (file as NSString).pathExtension.lowercased()
                    return ["png", "jpg", "jpeg", "gif"].contains(ext)
                }.sorted()
                
                if imageFiles.isEmpty {
                    print("  ❌ Bundle中没有图片文件")
                    print("  💡 提示：图片可能在Assets.xcassets中")
                } else {
                    for file in imageFiles.prefix(10) {
                        print("  📸 \(file)")
                    }
                    if imageFiles.count > 10 {
                        print("  ... 还有 \(imageFiles.count - 10) 个文件")
                    }
                }
            } catch {
                print("  ❌ 读取Bundle失败: \(error)")
            }
        }
        
        // Check Assets.car file
        print("\n🔍 Assets信息:")
        if let assetsPath = Bundle.main.path(forResource: "Assets", ofType: "car") {
            print("  ✅ 找到Assets.car文件: \(assetsPath)")
            print("  💡 图片应该在Assets.xcassets中，使用Image(\"\(word.imageName)\")访问")
        } else {
            print("  ❌ 未找到Assets.car文件")
        }
    }
    
    private func playAudio() {
        print("🔍 当前词: \(word.canonical), 片段数量: \(word.audioSegments.count)")
        for s in word.audioSegments {
            print("  ▶︎ \(s.startTime)-\(s.endTime), form: \(s.formType), file: \(s.audioFile?.fileName ?? "nil")")
        }

        // First try to use audio segments with timestamps
        if let audioSegment = word.audioSegments.first,
           let audioFile = audioSegment.audioFile {
            
            // Use toggle playback with timestamps
            audioManager.togglePlayback(
                filename: audioFile.fileName,
                startTime: audioSegment.startTime,
                endTime: audioSegment.endTime
            ) { success in
                if !success {
                    print("播放音频片段失败")
                    self.playFallbackAudio()
                }
            }
            return
        }
        
        // Fallback: try to find individual word audio files
        if let audioFileName = findAudioFile(for: word) {
            audioManager.togglePlayback(filename: audioFileName) { success in
                if !success {
                    print("播放音频失败: \(audioFileName)")
                    self.playFallbackAudio()
                }
            }
        } else {
            playFallbackAudio()
        }
    }
    
    private func findAudioFile(for word: Word) -> String? {
        // Check if word has audio segments
        if !word.audioSegments.isEmpty {
            // Use the first audio segment's file
            if let audioFile = word.audioSegments.first?.audioFile {
                return audioFile.fileName
            }
        }
        
        // Try different audio file naming patterns
        let possibleAudioNames = [
            word.canonical,
            word.canonical.replacingOccurrences(of: " ", with: "_"),
            word.canonical.replacingOccurrences(of: "'", with: "_"),
            word.id,
            "\(word.canonical)_audio"
        ]
        
        for audioName in possibleAudioNames {
            let exts = ["wav", "mp3", "m4a", "aac"]
            for ext in exts {
                if Bundle.main.url(forResource: audioName, withExtension: ext) != nil {
                    return audioName
                }
            }
        }
        
        return nil
    }
    
    private func playFallbackAudio() {
        // Your main audio file with all pronunciation
        let mainAudioFileName = "alloy_gpt-4o-mini-tts_0-75x_2025-09-23T22_28_54-859Z"
        
        print("🔊 尝试播放主音频文件: \(mainAudioFileName)")
        
        // Check if the file exists in Bundle
        let extensions = ["wav", "mp3", "m4a", "aac"]
        var foundAudio = false
        
        for ext in extensions {
            if let audioURL = Bundle.main.url(forResource: mainAudioFileName, withExtension: ext) {
                print("✅ 找到音频文件: \(audioURL.lastPathComponent) - 路径: \(audioURL.path)")
                audioManager.togglePlayback(filename: mainAudioFileName) { success in
                    if success {
                        print("✅ 成功播放音频: \(mainAudioFileName).\(ext)")
                    } else {
                        print("❌ 播放失败: \(mainAudioFileName).\(ext)")
                    }
                }
                foundAudio = true
                break
            }
        }
        
        if !foundAudio {
            print("❌ 未找到主音频文件: \(mainAudioFileName)")
            print("🔍 检查Bundle中的音频文件:")
            
            // Debug: Check what audio files are actually in the bundle
            if let bundlePath = Bundle.main.resourcePath {
                do {
                    let contents = try FileManager.default.contentsOfDirectory(atPath: bundlePath)
                    let audioFiles = contents.filter { file in
                        let ext = (file as NSString).pathExtension.lowercased()
                        return ["wav", "mp3", "m4a", "aac", "flac"].contains(ext)
                    }.sorted()
                    
                    if audioFiles.isEmpty {
                        print("  ❌ Bundle中没有音频文件")
                        print("  💡 提示：请将音频文件直接拖拽到Xcode项目中（不是Assets）")
                    } else {
                        print("  📦 Bundle中的音频文件:")
                        for file in audioFiles {
                            print("    🔊 \(file)")
                        }
                    }
                } catch {
                    print("  ❌ 读取Bundle失败: \(error)")
                }
            }
            
            tryOtherFallbackAudio()
        }
    }
    
    private func tryOtherFallbackAudio() {
        // List of other possible audio files to try as fallback
        let otherFallbackFiles = [
            "unite1_audio",
            "sample_audio",
            "default_pronunciation"
        ]
        
        for fileName in otherFallbackFiles {
            if Bundle.main.url(forResource: fileName, withExtension: "wav") != nil ||
               Bundle.main.url(forResource: fileName, withExtension: "mp3") != nil {
                audioManager.togglePlayback(filename: fileName) { success in
                    if success {
                        print("使用其他备用音频文件播放: \(fileName)")
                    }
                }
                break
            }
        }
    }
}
