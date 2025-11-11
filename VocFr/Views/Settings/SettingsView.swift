//
//  SettingsView.swift
//  VocFr
//
//  Created by Junfeng Wang on 22/09/2025.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        NavigationView {
            List {
                SwiftUI.Section("数据管理") {
                    Button("重新导入数据") {
                        reimportData()
                    }
                    
                    Button("导出学习报告") {
                        exportReport()
                    }
                }
                
                SwiftUI.Section("关于") {
                    HStack {
                        Text("版本")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("设置")
        }
    }
    
    private func reimportData() {
        // Clear existing data first
        do {
            let uniteDescriptor = FetchDescriptor<Unite>()
            let existingUnites = try modelContext.fetch(uniteDescriptor)
            for unite in existingUnites {
                modelContext.delete(unite)
            }
            
            try modelContext.save()
            
            // Reimport
            try FrenchVocabularySeeder.seedAllData(to: modelContext)
            FrenchVocabularySeeder.addAudioTimestamps(to: modelContext)
            
            print("数据重新导入完成")
        } catch {
            print("重新导入数据失败: \(error)")
        }
    }
    
    private func exportReport() {
        let report = FrenchVocabularySeeder.generateDataReport(from: modelContext)
        print(report)
        // TODO: Share report via share sheet
    }
}

struct SettingsPreview: View {
    var body: some View {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: Unite.self, Section.self, Word.self, WordForm.self,
                                           AudioFile.self, AudioSegment.self, UserProgress.self,
                                           WordProgress.self, PracticeRecord.self, SectionWord.self,
                                           configurations: config)
        
        return SettingsView()
            .modelContainer(container)
    }
}

#Preview {
    SettingsPreview()
}