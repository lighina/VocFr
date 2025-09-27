//
//  ContentView.swift
//  VocFr
//
//  Created by Junfeng Wang on 22/09/2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var showMainApp = false
    
    var body: some View {
        if showMainApp {
            MainAppView()
        } else {
            WelcomeView(showMainApp: $showMainApp)
        }
    }
}

struct WelcomeView: View {
    @Binding var showMainApp: Bool
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // App Icon/Logo
            VStack(spacing: 20) {
                Image(systemName: "book.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                Text("法语学习")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("开始您的法语学习之旅")
                    .font(.title2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            // Features
            VStack(alignment: .leading, spacing: 20) {
                WelcomeFeatureRow(icon: "book.closed", title: "丰富课程", description: "系统化的法语学习内容")
                WelcomeFeatureRow(icon: "waveform", title: "音频练习", description: "标准法语发音指导")
                WelcomeFeatureRow(icon: "chart.line.uptrend.xyaxis", title: "学习进度", description: "追踪您的学习成就")
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Start Learning Button
            Button(action: {
                withAnimation(.easeInOut(duration: 0.6)) {
                    showMainApp = true
                }
            }) {
                HStack {
                    Image(systemName: "play.circle.fill")
                        .font(.title2)
                    Text("开始学习")
                        .font(.title2)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [.blue, .blue.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(15)
                .shadow(color: .blue.opacity(0.3), radius: 10, y: 5)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 50)
        }
        .background(
            LinearGradient(
                colors: [Color.primary.opacity(0.05), Color.secondary.opacity(0.1)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

struct WelcomeFeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30, height: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

struct MainAppView: View {
    var body: some View {
        TabView {
            UnitsView()
                .tabItem {
                    Image(systemName: "book.closed")
                    Text("课程")
                }
            
            ProgressView()
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("进度")
                }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("设置")
                }
        }
    }
}

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

struct SectionDetailView: View {
    let section: Section
    
    var body: some View {
        VStack(spacing: 0) {
            // Practice button at top
            NavigationLink {
                PracticeView(section: section)
            } label: {
                HStack {
                    Image(systemName: "play.circle.fill")
                    Text("开始练习")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
            }
            .padding()
            
            // Word list
            List {
                ForEach(section.sectionWords.sorted(by: { $0.orderIndex < $1.orderIndex })) { sectionWord in
                    if let word = sectionWord.word {
                        WordRowView(word: word)
                    }
                }
            }
        }
        .navigationTitle(section.name.capitalized)
    }
}

struct WordRowView: View {
    let word: Word
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(word.canonical)
                    .font(.headline)
                Text(word.chinese)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(word.partOfSpeech.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(4)
                
                if let mainForm = word.forms.first(where: { $0.isMainForm }) {
                    Text(mainForm.french)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 2)
    }
}

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
                    
                    Button("检查图片资源") {
                        checkImageAssets()
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
    
    private func checkImageAssets() {
        let report = FrenchVocabularySeeder.validateImageAssets()
        print(report)
        // TODO: Show report in UI or share sheet
    }
}

#Preview("Welcome Screen") {
    ContentView()
        .modelContainer(for: [Unite.self, Section.self, Word.self, WordForm.self,
                              AudioFile.self, AudioSegment.self, UserProgress.self,
                              WordProgress.self, PracticeRecord.self, SectionWord.self], inMemory: true)
}

#Preview("Main App") {
    MainAppView()
        .modelContainer(for: [Unite.self, Section.self, Word.self, WordForm.self,
                              AudioFile.self, AudioSegment.self, UserProgress.self,
                              WordProgress.self, PracticeRecord.self, SectionWord.self], inMemory: true)
}
