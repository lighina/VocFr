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
    @State private var viewModel = UnitsViewModel()
    @State private var showImportAlert = false

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
                    Button(action: importData) {
                        Label("Import Data", systemImage: viewModel.isImporting ? "arrow.down.circle" : "square.and.arrow.down")
                    }
                    .disabled(viewModel.isImporting)
                }
            }
            .onAppear {
                // Initialize ViewModel with ModelContext
                viewModel = UnitsViewModel(modelContext: modelContext)
            }
            .alert("数据导入", isPresented: $showImportAlert) {
                Button("确定") {
                    viewModel.resetImportStatus()
                }
            } message: {
                if viewModel.importSucceeded {
                    Text("数据导入成功！")
                } else if let errorMessage = viewModel.errorMessage {
                    Text("导入失败：\(errorMessage)")
                }
            }
        }
    }

    private func importData() {
        viewModel.importData()
        showImportAlert = true
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