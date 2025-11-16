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
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var navigationCoordinator: NavigationCoordinator
    @State private var shouldDismiss = false

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
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            // Custom back button (leading)
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text(getUniteName())
                            .font(.system(size: 16))
                    }
                }
            }

            // Navigation menu
            ToolbarItem(placement: .navigationBarLeading) {
                Menu {
                    Button(action: {
                        navigationCoordinator.popToRoot()
                    }) {
                        Label("Home", systemImage: "house")
                    }
                    Button(action: {
                        dismiss()
                    }) {
                        Label(getUniteName(), systemImage: "book.closed")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 16))
                }
            }

            #if os(iOS)
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    NavigationLink(destination: PracticeView(section: section)) {
                        Label("section.practice.visual".localized, systemImage: "photo")
                    }
                    NavigationLink(destination: ListeningPracticeView(section: section)) {
                        Label("section.practice.listening".localized, systemImage: "speaker.wave.3")
                    }
                    NavigationLink(destination: FlashcardView(section: section)) {
                        Label("section.practice.flashcard".localized, systemImage: "rectangle.stack")
                    }
                    NavigationLink(destination: SpellingPracticeView(section: section)) {
                        Label("section.practice.spelling".localized, systemImage: "keyboard")
                    }
                    NavigationLink(destination: MatchingGameView(section: section)) {
                        Label("section.practice.matching".localized, systemImage: "rectangle.on.rectangle")
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 16, weight: .medium))
                        Text("section.button.practice".localized)
                            .font(.system(size: 14, weight: .medium))
                    }
                }
            }
            #else
            ToolbarItem(placement: .automatic) {
                Menu {
                    NavigationLink(destination: PracticeView(section: section)) {
                        Label("section.practice.visual".localized, systemImage: "photo")
                    }
                    NavigationLink(destination: ListeningPracticeView(section: section)) {
                        Label("section.practice.listening".localized, systemImage: "speaker.wave.3")
                    }
                    NavigationLink(destination: FlashcardView(section: section)) {
                        Label("section.practice.flashcard".localized, systemImage: "rectangle.stack")
                    }
                    NavigationLink(destination: SpellingPracticeView(section: section)) {
                        Label("section.practice.spelling".localized, systemImage: "keyboard")
                    }
                    NavigationLink(destination: MatchingGameView(section: section)) {
                        Label("section.practice.matching".localized, systemImage: "rectangle.on.rectangle")
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 16, weight: .medium))
                        Text("section.button.practice".localized)
                            .font(.system(size: 14, weight: .medium))
                    }
                }
            }
            #endif
        }
        .onChange(of: navigationCoordinator.popToRootTrigger) { _, _ in
            // Dismiss when popToRoot is triggered
            dismiss()
        }
    }

    private func getUniteName() -> String {
        if let unite = section.unite {
            return "Unité \(unite.number)"
        }
        return "Unit"
    }
}

#Preview("Section View") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Unite.self, Section.self, Word.self, WordForm.self,
                                       AudioFile.self, AudioSegment.self, UserProgress.self,
                                       WordProgress.self, PracticeRecord.self, SectionWord.self,
                                       FlashcardProgress.self, configurations: config)

    let section = Section(id: "preview-section", name: "preview section", orderIndex: 0)
    container.mainContext.insert(section)

    return NavigationStack {
        SectionDetailView(section: section)
    }
    .environmentObject(NavigationCoordinator())
    .modelContainer(container)
}
