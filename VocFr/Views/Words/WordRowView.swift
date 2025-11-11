//
//  WordRowView.swift
//  VocFr
//
//  Created by Junfeng Wang on 22/09/2025.
//

import SwiftUI
import SwiftData

struct WordRowView: View {
    let word: Word
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(word.canonical)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(word.chinese)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(getGrammaticalLabel(for: word.partOfSpeech))
                    .font(.caption)
                    .italic()
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(4)
                
                if let mainForm = word.forms.first(where: { $0.formType == .baseForm }) {
                    Text(mainForm.french)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 2)
    }
    
    // Helper function to convert part of speech to French
    private func getGrammaticalLabel(for partOfSpeech: PartOfSpeech) -> String {
        switch partOfSpeech {
        case .noun:
            return "nom"
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
        }
    }
}

struct WordRowPreview: View {
    var body: some View {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: Unite.self, Section.self, Word.self, WordForm.self,
                                           AudioFile.self, AudioSegment.self, UserProgress.self,
                                           WordProgress.self, PracticeRecord.self, SectionWord.self,
                                           configurations: config)
        
        let word = Word(id: "preview-word", canonical: "bonjour", chinese: "你好", imageName: "", partOfSpeech: .noun, category: "greetings")
        let wordForm = WordForm(formType: .baseForm, french: "bonjour", isMainForm: true)
        wordForm.word = word
        word.forms.append(wordForm)
        
        container.mainContext.insert(word)
        container.mainContext.insert(wordForm)
        
        return List {
            WordRowView(word: word)
        }
        .modelContainer(container)
    }
}

#Preview {
    WordRowPreview()
}