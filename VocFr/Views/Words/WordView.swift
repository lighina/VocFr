//
//  WordView.swift
//  VocFr
//
//  Created by Junfeng Wang on 22/09/2025.
//  Refactored with NavigationStack on 15/11/2025
//

import SwiftUI
import SwiftData
import AVFoundation

// Clean minimalist WordDetailView with swipe navigation
struct WordDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var audioManager = AudioPlayerManager.shared
    @State private var viewModel: WordDetailViewModel
    @Binding var navigationPath: NavigationPath

    init(section: Section, currentWordIndex: Int, navigationPath: Binding<NavigationPath>) {
        // Initialize ViewModel
        self._viewModel = State(initialValue: WordDetailViewModel(section: section, currentWordIndex: currentWordIndex))
        self._navigationPath = navigationPath
    }

    // Computed property to get current word (delegate to ViewModel)
    private var currentWord: Word? {
        viewModel.currentWord
    }

    // Navigation properties (delegate to ViewModel)
    private var canGoToPrevious: Bool {
        viewModel.canGoToPrevious
    }

    private var canGoToNext: Bool {
        viewModel.canGoToNext
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
                                viewModel.showCard()
                            }
                        }

                        // Hint when card is hidden
                        if !viewModel.showWordCard {
                            Text("Touchez l'image pour afficher la carte du mot")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }

                        // Word display - updated card style
                        if viewModel.showWordCard {
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
                .toolbar {
                    // Breadcrumb navigation
                    ToolbarItem(placement: .principal) {
                        BreadcrumbView(items: getBreadcrumbItems())
                    }

                    // Navigation menu (leading)
                    ToolbarItem(placement: .navigationBarLeading) {
                        Menu {
                            Button(action: {
                                navigationPath = NavigationPath()  // Clear all to go to root
                            }) {
                                Label("Home", systemImage: "house")
                            }
                            Button(action: {
                                navigationPath.removeLast(2)  // Remove 2 levels: Word -> Section -> Unite
                            }) {
                                Label(getUniteName(), systemImage: "book.closed")
                            }
                            Button(action: {
                                navigationPath.removeLast()  // Remove 1 level: Word -> Section
                            }) {
                                Label(viewModel.section.name.capitalized, systemImage: "list.dash")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .font(.system(size: 20))
                        }
                    }

                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack(spacing: 8) {
                            // Word card toggle
                            ToolbarIconButton(
                                icon: viewModel.showWordCard ? "eye.fill" : "eye",
                                isActive: viewModel.showWordCard,
                                activeColor: .blue
                            ) {
                                viewModel.toggleWordCard()
                            }

                            // Shuffle toggle
                            ToolbarIconButton(
                                icon: "shuffle",
                                isActive: viewModel.isShuffled,
                                activeColor: .green
                            ) {
                                toggleShuffle()
                            }
                        }
                    }
                }
                .gesture(
                    DragGesture()
                        .onEnded { value in
                            handleSwipeGesture(value)
                        }
                )
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
                        return "n. (m.)"
                    case .feminine:
                        return "n. (f.)"
                    }
                }

                // Check form type for gender clues
                let formType = mainForm.formType.rawValue.lowercased()
                if formType.contains("masculin") || formType.contains("m.") {
                    return "n. (m.)"
                } else if formType.contains("féminin") || formType.contains("f.") {
                    return "n. (f.)"
                }
            }
            
            // Fallback gender guess
            if word.canonical.hasSuffix("e") && !word.canonical.hasSuffix("le") && !word.canonical.hasSuffix("re") {
                return "n. (f.)"
            } else {
                return "n. (m.)"
            }
        }
        
        // For other parts of speech, convert Chinese to French
        switch word.partOfSpeech {
        case .verb:
            return "v."
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
            return "n." // fallback, should be handled above
        }
    }
    
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
        withAnimation(.easeInOut(duration: 0.3)) {
            viewModel.goToPrevious()
        }

        // Provide haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }

    private func goToNext() {
        withAnimation(.easeInOut(duration: 0.3)) {
            viewModel.goToNext()
        }

        // Provide haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }

    private func toggleShuffle() {
        viewModel.toggleShuffle()

        // Provide haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    private func playAudio(for word: Word) {
        // Toggle playback if already playing
        if audioManager.isPlaying {
            audioManager.stopAudio()
            return
        }

        // Use the new unified playWordAudio method (Phase 2.6)
        // Pass the section context to handle words that appear in multiple sections
        // (e.g., "orange" as both adjective in U1S2 and noun in U2S2)
        // This automatically tries:
        // 1. Independent audio files (Unite/Section/*.mp3)
        // 2. Timestamp-based audio segments (backward compatible)
        // 3. Fallback handling
        audioManager.playWordAudio(for: word, in: viewModel.section) { success in
            if !success {
                print("⚠️ Failed to play audio for '\(word.canonical)', trying fallback")
                self.playFallbackAudio(for: word)
            }
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

    // MARK: - Navigation Helpers

    private func getBreadcrumbItems() -> [BreadcrumbItem] {
        var items: [BreadcrumbItem] = [BreadcrumbItem(title: "🏠")]

        if let unite = viewModel.section.unite {
            items.append(BreadcrumbItem(title: "Unité \(unite.number)"))
        }

        items.append(BreadcrumbItem(title: viewModel.section.name.capitalized))

        if let word = currentWord {
            items.append(BreadcrumbItem(title: getBaseWord(for: word)))
        }

        return items
    }

    private func getUniteName() -> String {
        if let unite = viewModel.section.unite {
            return "Unité \(unite.number)"
        }
        return "Unit"
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
        
        @State var path = NavigationPath()

        return WordDetailView(section: section, currentWordIndex: 0, navigationPath: $path)
            .modelContainer(container)
    }
}

#Preview("Word Detail") {
    WordDetailPreview()
}
