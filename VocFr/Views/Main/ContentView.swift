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
    @StateObject private var navigationCoordinator = NavigationCoordinator()

    var body: some View {
        if showMainApp {
            NavigationStack {
                MainAppView()
            }
            .environmentObject(navigationCoordinator)
            .onChange(of: navigationCoordinator.popToRootTrigger) { _, newValue in
                // When popToRoot is triggered, dismiss all presented views
                // This is handled by individual views listening to the coordinator
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
