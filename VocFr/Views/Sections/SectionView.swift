//
//  SectionView.swift
//  VocFr
//
//  Created by Junfeng Wang on 22/09/2025.
//

import SwiftUI
import SwiftData

struct SectionDetailView: View {
    @Environment(\.dismiss) private var dismiss
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
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            // Breadcrumb navigation in title
            ToolbarItem(placement: .principal) {
                BreadcrumbView(items: [
                    BreadcrumbItem(title: "🏠"),
                    BreadcrumbItem(title: getUniteName()),
                    BreadcrumbItem(title: section.name.capitalized)
                ])
            }

            // Quick navigation menu
            ToolbarItem(placement: .navigationBarLeading) {
                QuickNavigationMenu(items: [
                    QuickNavItem(title: "Home", icon: "house") {
                        dismissToRoot()
                    },
                    QuickNavItem(title: "Unit List", icon: "list.bullet") {
                        dismiss()
                    }
                ])
            }

            #if os(iOS)
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: PracticeView(section: section)) {
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
                NavigationLink(destination: PracticeView(section: section)) {
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

    private func dismissToRoot() {
        // Dismiss multiple times to get to root
        // This is a simple approach; more sophisticated navigation state management could be used
        dismiss()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            dismiss()
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