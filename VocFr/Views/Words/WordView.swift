//
//  WordView.swift
//  VocFr
//
//  Created by Junfeng Wang on 22/09/2025.
//

import SwiftUI
import SwiftData
import AVFoundation

// Clean minimalist WordDetailView with swipe navigation
struct WordDetailView: View {
    let section: Section
    @State private var currentWordIndex: Int
    @State private var showWordCard = true
    @State private var isShuffled = false
    @State private var shuffledWords: [SectionWord] = []
    @State private var originalWords: [SectionWord] = []
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var audioManager = AudioPlayerManager.shared
    
    // Computed property to get current word
    private var currentWord: Word? {
        let wordsToUse = isShuffled ? shuffledWords : originalWords
        guard currentWordIndex >= 0 && currentWordIndex < wordsToUse.count,
              let word = wordsToUse[currentWordIndex].word else {
            return nil
        }
        return word
    }
    
    // Computed properties for navigation
    private var canGoToPrevious: Bool {
        currentWordIndex > 0
    }
    
    private var canGoToNext: Bool {
        let wordsToUse = isShuffled ? shuffledWords : originalWords
        return currentWordIndex < wordsToUse.count - 1
    }
    
    init(section: Section, currentWordIndex: Int) {
        self.section = section
        self._currentWordIndex = State(initialValue: currentWordIndex)
        
        // Initialize with sorted words
        let sortedWords = section.sectionWords.sorted(by: { $0.orderIndex < $1.orderIndex })
        self._originalWords = State(initialValue: sortedWords)
        self._shuffledWords = State(initialValue: sortedWords.shuffled())
    }
    
    var body: some View {
        Group {
            if let word = currentWord {
                VStack(spacing: 0) {
                    Spacer()
                    
                    // Main content area
                    VStack(spacing: 40) {
                        // Word image - large and centered
                        Group {
                            if !word.imageName.isEmpty && imageExists(named: word.imageName) {

                                Image(word.imageName)

                                    .resizable()

                                    .aspectRatio(contentMode: .fit)

                                    .frame(maxWidth: 250, maxHeight: 250)

                            } else {

                                // Placeholder - shown when image name is empty or image file doesn't exist

                                RoundedRectangle(cornerRadius: 20)

                                    .fill(Color.gray.opacity(0.2))

                                    .frame(width: 250, height: 200)

                                    .overlay(

                                        Image(systemName: "photo")

                                            .font(.system(size: 40))

                                            .foregroundColor(.gray.opacity(0.6))

                                    )

                            }
                        }
                        .id(word.id) // For smooth animation
                        .onTapGesture {
                            withAnimation(.easeInOut) {
                                showWordCard = true
                            }
                        }
                        
                        // Hint when card is hidden
                        if !showWordCard {
                            Text("Touchez l’image pour afficher la carte du mot")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                        
                        // Word display - updated card style
                        if showWordCard {
                            VStack(spacing: 16) {
                                // Main word line (for nouns, show base word; others show canonical)
                                Text(getWordTitle(for: word))
                                    .font(.system(size: 36, weight: .medium, design: .default))
                                    .foregroundColor(.black)
                                    .multilineTextAlignment(.center)

                                // Grammatical indicator
                                Text(getGrammaticalIndicator(for: word))
                                    .font(.system(size: 16, weight: .regular, design: .default))
                                    .foregroundStyle(.secondary)
                                    .italic()

                                // Audio button
                                Button(action: { playAudio(for: word) }) {
                                    Image(systemName: audioManager.isPlaying ? "stop.fill" : "play.fill")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white)
                                        .frame(width: 44, height: 44)
                                        .background(Color.blue)
                                        .clipShape(Circle())
                                }
                                .animation(.easeInOut(duration: 0.2), value: audioManager.isPlaying)

                                // Articles inside the card (for nouns)
                                if word.partOfSpeech == .noun {
                                    articleBlock(for: word)
                                        .padding(.top, 4)
                                }
                            }
                            .padding(.top, 24)
                            .padding(.bottom, 28)
                            .padding(.horizontal, 24)
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(24)
                            .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
                            .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)
                        }
                    }
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, 20)
                .background(Color(.systemBackground))
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                                .foregroundColor(.primary)
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack(spacing: 12) {
                            // Word card toggle
                            Button(action: { showWordCard.toggle() }) {
                                Image(systemName: showWordCard ? "eye.fill" : "eye")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(showWordCard ? .blue : .secondary)
                                    .frame(width: 44, height: 32)
                                    .background(showWordCard ? Color.blue.opacity(0.1) : Color.clear)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            .animation(.easeInOut(duration: 0.2), value: showWordCard)
                            
                            // Shuffle toggle
                            Button(action: { toggleShuffle() }) {
                                Image(systemName: isShuffled ? "shuffle" : "shuffle")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(isShuffled ? .green : .secondary)
                                    .frame(width: 44, height: 32)
                                    .background(isShuffled ? Color.green.opacity(0.1) : Color.clear)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            .animation(.easeInOut(duration: 0.2), value: isShuffled)
                        }
                    }
                }
                .gesture(
                    DragGesture()
                        .onEnded { value in
                            handleSwipeGesture(value)
                        }
                )
                .animation(.easeInOut(duration: 0.3), value: currentWordIndex)
                .onAppear {
                    // Ensure original words are properly initialized
                    if originalWords.isEmpty {
                        originalWords = section.sectionWords.sorted(by: { $0.orderIndex < $1.orderIndex })
                        shuffledWords = originalWords.shuffled()
                    }
                }
            } else {
                // Fallback if no word is found
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 60))
                        .foregroundColor(.orange)
                    
                    Text("未找到单词")
                        .font(.title2)
                        .fontWeight(.semibold)
                }
                .navigationTitle("单词")
            }
        }
    }
    
    // MARK: - Helper Functions
    /// Check if an image exists in the asset catalog
    private func imageExists(named: String) -> Bool {
        #if os(iOS)
        return UIImage(named: named) != nil
        #elseif os(macOS)
        return NSImage(named: named) != nil
        #else
        return false
        #endif
    }
    
    // Helper function to get word with appropriate article
    private func getWordWithArticle(for word: Word) -> String {
        // For nouns, show just the base word without article (articles are shown separately below)
        if word.partOfSpeech == .noun {
            return getBaseWord(for: word)
        }
        
        // For other parts of speech, return as is
        return word.canonical
    }
    
    // Title for the word card
    private func getWordTitle(for word: Word) -> String {
        if word.partOfSpeech == .noun { return getBaseWord(for: word) }
        return word.canonical
    }

    // Helper function to get grammatical indicator in French
    private func getGrammaticalIndicator(for word: Word) -> String {
        if word.partOfSpeech == .noun {
            if let mainForm = word.forms.first(where: { $0.isMainForm }) {
                if let gender = mainForm.gender {
                    switch gender {
                    case .masculine:
                        return "nom (m.)"
                    case .feminine:
                        return "nom (f.)"
                    }
                }
                
                // Check form type for gender clues
                let formType = mainForm.formType.rawValue.lowercased()
                if formType.contains("masculin") || formType.contains("m.") {
                    return "nom (m.)"
                } else if formType.contains("féminin") || formType.contains("f.") {
                    return "nom (f.)"
                }
            }
            
            // Fallback gender guess
            if word.canonical.hasSuffix("e") && !word.canonical.hasSuffix("le") && !word.canonical.hasSuffix("re") {
                return "nom (f.)"
            } else {
                return "nom (m.)"
            }
        }
        
        // For other parts of speech, convert Chinese to French
        switch word.partOfSpeech {
        case .verb:
            return "verbe"
        case .adjective:
            return "adj."
        case .number:
            return "num."
        case .pronoun:
            return "pron."
        case .preposition:
            return "prép."
        case .other:
            return "autre"
        case .noun:
            return "nom" // fallback, should be handled above
        }
    }
    
    // Build articles block inside the card
    @ViewBuilder
    private func articleBlock(for word: Word) -> some View {
        let gender = determineGender(for: word)
        let base = getBaseWord(for: word)
        VStack(alignment: .leading, spacing: 8) {
            // Definite
            VStack(alignment: .leading, spacing: 4) {
                Text("Défini:")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                Text(definiteSingular(for: base, gender: gender))
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.secondary)
                Text("les \(pluralized(base))")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            // Indefinite
            VStack(alignment: .leading, spacing: 4) {
                Text("Indéfini:")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                Text(indefiniteSingular(for: base, gender: gender))
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.secondary)
                Text("des \(pluralized(base))")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.secondary)
            }
        }
    }

    // Elision helpers
    private func beginsWithVowelOrH(_ word: String) -> Bool {
        let lower = word.lowercased()
        let vowels = ["a","e","i","o","u","y","à","â","ä","é","è","ê","ë","î","ï","ô","ö","ù","û","ü","h"]
        return vowels.contains { lower.hasPrefix($0) }
    }

    private func definiteSingular(for base: String, gender: Gender) -> String {
        if beginsWithVowelOrH(base) { return "l'\(base)" }
        return (gender == .masculine ? "le " : "la ") + base
    }

    private func indefiniteSingular(for base: String, gender: Gender) -> String {
        return (gender == .masculine ? "un " : "une ") + base
    }

    private func pluralized(_ base: String) -> String { return base + "s" }
    
    // Helper function to determine gender
    private func determineGender(for word: Word) -> Gender {
        if let mainForm = word.forms.first(where: { $0.isMainForm }) {
            if let gender = mainForm.gender {
                return gender
            }
            
            // Check form type for gender clues
            let formType = mainForm.formType.rawValue.lowercased()
            if formType.contains("masculin") || formType.contains("m.") {
                return .masculine
            } else if formType.contains("féminin") || formType.contains("f.") {
                return .feminine
            }
        }
        
        // Fallback gender guess based on word ending
        if word.canonical.hasSuffix("e") && !word.canonical.hasSuffix("le") && !word.canonical.hasSuffix("re") {
            return .feminine
        } else {
            return .masculine
        }
    }
    
    // Helper function to get the base word without articles
    private func getBaseWord(for word: Word) -> String {
        let wordsWithArticles = ["le ", "la ", "les ", "un ", "une ", "des "]
        let lowercaseCanonical = word.canonical.lowercased()
        
        for article in wordsWithArticles {
            if lowercaseCanonical.hasPrefix(article) {
                return String(word.canonical.dropFirst(article.count))
            }
        }
        
        return word.canonical
    }
    
    private func handleSwipeGesture(_ value: DragGesture.Value) {
        let swipeThreshold: CGFloat = 50
        
        // Horizontal swipes for navigation
        if abs(value.translation.width) > abs(value.translation.height) {
            if value.translation.width > swipeThreshold {
                // Swipe right - go to previous word
                goToPrevious()
            } else if value.translation.width < -swipeThreshold {
                // Swipe left - go to next word
                goToNext()
            }
        }
        // Vertical swipe down to go back
        else if value.translation.height > swipeThreshold * 1.5 {
            // Swipe down - go back
            dismiss()
        }
    }
    
    private func goToPrevious() {
        guard canGoToPrevious else { return }
        
        withAnimation(.easeInOut(duration: 0.3)) {
            currentWordIndex -= 1
        }
        
        // Provide haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    private func goToNext() {
        guard canGoToNext else { return }
        
        withAnimation(.easeInOut(duration: 0.3)) {
            currentWordIndex += 1
        }
        
        // Provide haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    private func toggleShuffle() {
        // Find current word to maintain position after shuffle
        let currentWordId = currentWord?.id
        
        // Toggle shuffle state
        isShuffled.toggle()
        
        // Provide haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        if isShuffled {
            // Re-shuffle the words to get a new random order
            shuffledWords = originalWords.shuffled()
            
            // Try to find the current word in the new shuffled order
            if let currentWordId = currentWordId,
               let newIndex = shuffledWords.firstIndex(where: { $0.word?.id == currentWordId }) {
                currentWordIndex = newIndex
            } else {
                // If we can't find the current word, start from beginning
                currentWordIndex = 0
            }
        } else {
            // Return to original order and find current word's original position
            if let currentWordId = currentWordId,
               let originalIndex = originalWords.firstIndex(where: { $0.word?.id == currentWordId }) {
                currentWordIndex = originalIndex
            } else {
                currentWordIndex = 0
            }
        }
    }
    
    private func playAudio(for word: Word) {
        // First try to use audio segments with timestamps (preferred method)
        if let audioSegment = word.audioSegments.first,
           let audioFile = audioSegment.audioFile {
            
            print("🔊 播放单词 '\(word.canonical)' 的音频片段:")
            print("   文件: \(audioFile.filePath)")
            print("   起始时间: \(audioSegment.startTime)s")
            print("   结束时间: \(audioSegment.endTime)s")
            print("   片段长度: \(audioSegment.endTime - audioSegment.startTime)s")
            
            // Use toggle playback with timestamps for precise word pronunciation
            audioManager.togglePlayback(
                filename: audioFile.fileName,
                startTime: audioSegment.startTime,
                endTime: audioSegment.endTime
            ) { success in
                if success {
                    print("✅ 成功播放单词 '\(word.canonical)' 的音频片段")
                } else {
                    print("❌ 播放音频片段失败，尝试备用方法")
                    self.playFallbackAudio(for: word)
                }
            }
            return
        }
        
        // Fallback: try to find individual word audio files
        if let audioFileName = findAudioFile(for: word) {
            print("🔊 播放单词 '\(word.canonical)' 的独立音频文件: \(audioFileName)")
            audioManager.togglePlayback(filename: audioFileName) { success in
                if !success {
                    print("播放独立音频失败: \(audioFileName)")
                    self.playFallbackAudio(for: word)
                }
            }
        } else {
            print("⚠️ 未找到单词 '\(word.canonical)' 的音频片段或独立文件，播放完整音频")
            playFallbackAudio(for: word)
        }
    }
    
    private func findAudioFile(for word: Word) -> String? {
        // Check if word has audio segments
        if !word.audioSegments.isEmpty {
            if let audioFile = word.audioSegments.first?.audioFile {
                return audioFile.filePath
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
            if Bundle.main.url(forResource: audioName, withExtension: "wav") != nil ||
               Bundle.main.url(forResource: audioName, withExtension: "mp3") != nil ||
               Bundle.main.url(forResource: audioName, withExtension: "m4a") != nil {
                return audioName
            }
        }
        
        return nil
    }
    
    private func playFallbackAudio(for word: Word) {
        // Main audio file with all pronunciations
        let mainAudioFileName = "alloy_gpt-4o-mini-tts_0-75x_2025-09-23T22_28_54-859Z"
        
        print("🔊 播放完整音频文件 (备用方案): \(mainAudioFileName)")
        print("⚠️ 注意：这将播放完整音频，而不是单个单词")
        
        let extensions = ["wav", "mp3", "m4a", "aac"]
        for ext in extensions {
            if Bundle.main.url(forResource: mainAudioFileName, withExtension: ext) != nil {
                audioManager.togglePlayback(filename: mainAudioFileName) { success in
                    if success {
                        print("✅ 播放主音频文件: \(mainAudioFileName).\(ext)")
                    } else {
                        print("❌ 播放失败: \(mainAudioFileName).\(ext)")
                    }
                }
                return
            }
        }
        
        print("❌ 未找到音频文件: \(mainAudioFileName)")
        print("💡 请检查音频文件是否已添加到项目中")
    }
}

struct WordDetailPreview: View {
    var body: some View {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: Unite.self, Section.self, Word.self, WordForm.self,
                                           AudioFile.self, AudioSegment.self, UserProgress.self,
                                           WordProgress.self, PracticeRecord.self, SectionWord.self,
                                           configurations: config)
        
        let context = container.mainContext
        
        // Create sample data for preview using the correct initializers
        let section = Section(id: "sample-section", name: "Sample Section", orderIndex: 0)
        let word = Word(id: "sample-word", canonical: "bonjour", chinese: "你好", imageName: "", partOfSpeech: .noun, category: "greetings")
        let sectionWord = SectionWord(orderIndex: 0)
        
        // Set up relationships
        sectionWord.section = section
        sectionWord.word = word
        section.sectionWords.append(sectionWord)
        word.sectionWords.append(sectionWord)
        
        context.insert(section)
        context.insert(word)
        context.insert(sectionWord)
        
        return WordDetailView(section: section, currentWordIndex: 0)
            .modelContainer(container)
    }
}

#Preview("Word Detail") {
    WordDetailPreview()
}
