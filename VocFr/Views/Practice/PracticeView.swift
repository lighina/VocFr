import SwiftUI
import SwiftData

struct PracticeView: View {
    let section: Section
    @Environment(\.modelContext) private var modelContext
    @State private var currentWordIndex = 0
    @State private var showAnswer = false
    @State private var correctCount = 0
    @State private var isCompleted = false
    
    private var words: [Word] {
        section.sectionWords
            .sorted(by: { $0.orderIndex < $1.orderIndex })
            .compactMap { $0.word }
    }
    
    private var currentWord: Word? {
        guard currentWordIndex < words.count else { return nil }
        return words[currentWordIndex]
    }
    
    var body: some View {
        VStack(spacing: 20) {
            if isCompleted {
                completedView
            } else if let word = currentWord {
                practiceCard(for: word)
            } else {
                Text("没有单词可以练习")
            }
        }
        .padding()
        .navigationTitle("练习: \(section.name)")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
    
    private func practiceCard(for word: Word) -> some View {
        VStack(spacing: 20) {
            // Progress indicator
            HStack {
                Text("\(currentWordIndex + 1) / \(words.count)")
                    .font(.caption)
                Spacer()
                Text("正确: \(correctCount)")
                    .font(.caption)
                    .foregroundColor(.green)
            }
            
            // Word card
            VStack(spacing: 15) {
                // French word
                Text(word.canonical)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                
                // Part of speech
                Text(word.partOfSpeech.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(8)
                
                // Main form (if available)
                if let mainForm = word.forms.first(where: { $0.isMainForm }) {
                    Text(mainForm.french)
                        .font(.title2)
                        .foregroundColor(.secondary)
                        .padding(.top, 10)
                }
                
                // Chinese translation (show after tap)
                if showAnswer {
                    Text(word.chinese)
                        .font(.title)
                        .foregroundColor(.primary)
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(10)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(.regularMaterial)
            .cornerRadius(15)
            .shadow(radius: 5)
            
            Spacer()
            
            // Action buttons
            if showAnswer {
                HStack(spacing: 20) {
                    Button("答错了") {
                        nextWord()
                    }
                    .buttonStyle(.bordered)
                    
                    Button("答对了") {
                        correctCount += 1
                        nextWord()
                    }
                    .buttonStyle(.borderedProminent)
                }
            } else {
                Button("显示答案") {
                    withAnimation(.spring(response: 0.5)) {
                        showAnswer = true
                    }
                }
                .buttonStyle(.borderedProminent)
                .font(.headline)
            }
        }
    }
    
    private var completedView: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            Text("练习完成！")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("正确率: \(Int(Double(correctCount) / Double(words.count) * 100))%")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Text("答对 \(correctCount) / \(words.count) 个单词")
                .font(.body)
                .foregroundColor(.secondary)
            
            Button("重新练习") {
                restartPractice()
            }
            .buttonStyle(.borderedProminent)
            .padding(.top)
        }
    }
    
    private func nextWord() {
        currentWordIndex += 1
        showAnswer = false
        
        if currentWordIndex >= words.count {
            withAnimation {
                isCompleted = true
            }
            savePracticeRecord()
        }
    }
    
    private func restartPractice() {
        currentWordIndex = 0
        showAnswer = false
        correctCount = 0
        isCompleted = false
    }
    
    private func savePracticeRecord() {
        let accuracy = Double(correctCount) / Double(words.count)
        let record = PracticeRecord(
            sessionDate: Date(),
            sessionType: "Section Practice",
            wordsStudied: words.count,
            accuracy: accuracy,
            timeSpent: 0 // TODO: Implement time tracking
        )
        
        modelContext.insert(record)
        
        do {
            try modelContext.save()
        } catch {
            print("保存练习记录失败: \(error)")
        }
    }
}

#Preview {
    NavigationView {
        PracticeView(section: Section(id: "test", name: "Test Section", orderIndex: 1))
    }
    .modelContainer(for: [Section.self, Word.self], inMemory: true)
}