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
                        dismissToRoot()
                    },
                    QuickNavItem(title: getUniteName(), icon: "book.closed") {
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
        // Dismiss to root (back to Units view)
        dismiss()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.dismiss()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.dismiss()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.dismiss()
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