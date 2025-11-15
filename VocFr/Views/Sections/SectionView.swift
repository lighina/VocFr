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
    @Binding var navigationPath: NavigationPath

    var body: some View {
        List {
            ForEach(Array(section.sectionWords.sorted(by: { $0.orderIndex < $1.orderIndex }).enumerated()), id: \.element.id) { index, sectionWord in
                if let word = sectionWord.word {
                    NavigationLink(value: WordNavigationData(section: section, wordIndex: index)) {
                        WordRowView(word: word)
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            // Breadcrumb navigation in leading position (replaces title)
            ToolbarItem(placement: .principal) {
                BreadcrumbView(items: [
                    BreadcrumbItem(title: "🏠"),
                    BreadcrumbItem(title: getUniteName()),
                    BreadcrumbItem(title: section.name.capitalized)
                ])
            }

            // Quick navigation menu (replaces back button)
            ToolbarItem(placement: .navigationBarLeading) {
                QuickNavigationMenu(items: [
                    QuickNavItem(title: "Home", icon: "house") {
                        navigationPath = NavigationPath()  // Clear path to go to root
                    },
                    QuickNavItem(title: getUniteName(), icon: "book.closed") {
                        navigationPath.removeLast()  // Go back one level
                    }
                ])
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
    }

    private func getUniteName() -> String {
        if let unite = section.unite {
            return "Unité \(unite.number)"
        }
        return "Unit"
    }
}

#Preview("Section View") {
    @Previewable @State var path = NavigationPath()

    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Unite.self, Section.self, Word.self, WordForm.self,
                                       AudioFile.self, AudioSegment.self, UserProgress.self,
                                       WordProgress.self, PracticeRecord.self, SectionWord.self,
                                       FlashcardProgress.self, configurations: config)

    let section = Section(id: "preview-section", name: "preview section", orderIndex: 0)
    container.mainContext.insert(section)

    return SectionDetailView(section: section, navigationPath: $path)
        .modelContainer(container)
}
