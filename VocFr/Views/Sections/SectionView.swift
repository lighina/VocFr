//
//  SectionView.swift
//  VocFr
//
//  Created by Junfeng Wang on 22/09/2025.
//

import SwiftUI
import SwiftData



struct SectionDetailView: View {
    let section: Section
    
    var body: some View {
        List {
            ForEach(Array(section.sectionWords.sorted(by: { $0.orderIndex < $1.orderIndex }).enumerated()), id: \.element.id) { index, sectionWord in
                if let word = sectionWord.word {
                    NavigationLink(destination: WordDetailView(section: section, currentWordIndex: index)) {
                        WordRowView(word: word)
                    }
                }
            }
        }
        .navigationTitle(section.name.capitalized)
        .toolbar {
            #if os(iOS)
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: PracticeView(section: section)) {
                    HStack {
                        Image(systemName: "play.circle.fill")
                        Text("section.button.practice".localized)
                    }
                }
            }
            #else
            ToolbarItem(placement: .automatic) {
                NavigationLink(destination: PracticeView(section: section)) {
                    HStack {
                        Image(systemName: "play.circle.fill")
                        Text("section.button.practice".localized)
                    }
                }
            }
            #endif
        }
    }
}

#Preview("Section View") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Unite.self, Section.self, Word.self, WordForm.self,
                                       AudioFile.self, AudioSegment.self, UserProgress.self,
                                       WordProgress.self, PracticeRecord.self, SectionWord.self,
                                       configurations: config)
    
    let section = Section(id: "preview-section", name: "preview section", orderIndex: 0)
    container.mainContext.insert(section)
    
    return SectionDetailView(section: section)
        .modelContainer(container)
}