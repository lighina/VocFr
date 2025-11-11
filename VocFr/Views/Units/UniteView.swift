//
//  UniteView.swift
//  VocFr
//
//  Created by Junfeng Wang on 22/09/2025.
//

import SwiftUI
import SwiftData

struct UnitsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var unites: [Unite]

    var body: some View {
        NavigationView {
            List {
                ForEach(unites.sorted(by: { $0.number < $1.number })) { unite in
                    NavigationLink {
                        UniteDetailView(unite: unite)
                    } label: {
                        UniteRowView(unite: unite)
                    }
                    .disabled(!unite.isUnlocked)
                    .opacity(unite.isUnlocked ? 1.0 : 0.6)
                }
            }
            .navigationTitle("法语学习")
            .toolbar {
                ToolbarItem {
                    Button(action: seedData) {
                        Label("Import Data", systemImage: "square.and.arrow.down")
                    }
                }
            }
        }
    }

    private func seedData() {
        do {
            try FrenchVocabularySeeder.seedAllData(to: modelContext)
        } catch {
            print("数据导入失败: \(error)")
        }
    }
}

struct UniteRowView: View {
    let unite: Unite
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Unité \(unite.number): \(unite.title)")
                    .font(.headline)
                Text("\(unite.sections.count) 个章节")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                if unite.isUnlocked {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                } else {
                    VStack {
                        Image(systemName: "lock")
                            .foregroundColor(.orange)
                        Text("需要 \(unite.requiredStars) 星")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct UniteDetailView: View {
    let unite: Unite
    
    var body: some View {
        List {
            ForEach(unite.sections.sorted(by: { $0.orderIndex < $1.orderIndex })) { section in
                NavigationLink {
                    SectionDetailView(section: section)
                } label: {
                    SectionRowView(section: section)
                }
            }
        }
        .navigationTitle(unite.title)
    }
}

struct SectionRowView: View {
    let section: Section
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(section.name.capitalized)
                .font(.headline)
            Text("\(section.sectionWords.count) 个单词")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 2)
    }
}

#Preview("Units View") {
    UnitsView()
        .modelContainer(for: [Unite.self, Section.self, Word.self, WordForm.self,
                              AudioFile.self, AudioSegment.self, UserProgress.self,
                              WordProgress.self, PracticeRecord.self, SectionWord.self], inMemory: true)
}