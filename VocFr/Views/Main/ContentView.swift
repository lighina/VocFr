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
            NavigationStack {
                MainAppView()
            }
        } else {
            WelcomeView(showMainApp: $showMainApp)
        }
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
