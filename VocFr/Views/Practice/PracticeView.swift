import SwiftUI
import SwiftData

struct PracticeView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: PracticeViewModel

    init(section: Section) {
        // Initialize viewModel with section
        // modelContext will be set in onAppear
        self._viewModel = State(initialValue: PracticeViewModel(section: section, modelContext: nil))
    }

    var body: some View {
        VStack(spacing: 20) {
            if viewModel.isCompleted {
                completedView
            } else if let word = viewModel.currentWord {
                practiceCard(for: word)
            } else {
                Text("没有单词可以练习")
            }
        }
        .padding()
        .navigationTitle("练习: \(viewModel.sectionName)")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .onAppear {
            // Set modelContext after view appears
            viewModel = PracticeViewModel(section: viewModel.section, modelContext: modelContext)
        }
    }
    
    private func practiceCard(for word: Word) -> some View {
        VStack(spacing: 20) {
            // Progress indicator
            HStack {
                Text(viewModel.progressText)
                    .font(.caption)
                Spacer()
                Text(viewModel.correctCountText)
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
                if viewModel.showAnswer {
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
            if viewModel.showAnswer {
                HStack(spacing: 20) {
                    Button("答错了") {
                        viewModel.markIncorrect()
                    }
                    .buttonStyle(.bordered)

                    Button("答对了") {
                        viewModel.markCorrect()
                    }
                    .buttonStyle(.borderedProminent)
                }
            } else {
                Button("显示答案") {
                    withAnimation(.spring(response: 0.5)) {
                        viewModel.showAnswerAction()
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

            Text(viewModel.accuracyText)
                .font(.title2)
                .foregroundColor(.secondary)

            Text(viewModel.resultsSummaryText)
                .font(.body)
                .foregroundColor(.secondary)

            Button("重新练习") {
                viewModel.restartPractice()
            }
            .buttonStyle(.borderedProminent)
            .padding(.top)
        }
    }
}

#Preview {
    NavigationView {
        PracticeView(section: Section(id: "test", name: "Test Section", orderIndex: 1))
    }
    .modelContainer(for: [Section.self, Word.self], inMemory: true)
}