//
//  MenuView.swift
//  VocFr
//
//  Created by Junfeng Wang on 22/09/2025.
//

import SwiftUI

// 菜单视图
struct MenuView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: AchievementView()) {
                    MenuRowView(icon: "trophy.fill", title: "menu.achievements.title".localized, description: "menu.achievements.description".localized)
                }

                NavigationLink(destination: ProgressView()) {
                    MenuRowView(icon: "chart.line.uptrend.xyaxis", title: "menu.progress.title".localized, description: "menu.progress.description".localized)
                }

                SwiftUI.Section(header: Text("menu.section.entertainment".localized)) {
                    NavigationLink(destination: GamesListView()) {
                        MenuRowView(icon: "gamecontroller.fill", title: "menu.games.title".localized, description: "menu.games.description".localized)
                    }

                    NavigationLink(destination: StorybooksListView()) {
                        MenuRowView(icon: "book.fill", title: "menu.storybooks.title".localized, description: "menu.storybooks.description".localized)
                    }
                }

                NavigationLink(destination: SettingsView()) {
                    MenuRowView(icon: "gearshape", title: "menu.settings.title".localized, description: "menu.settings.description".localized)
                }

                SwiftUI.Section {
                    MenuRowView(icon: "info.circle", title: "menu.about.title".localized, description: "menu.about.description".localized)
                    MenuRowView(icon: "questionmark.circle", title: "menu.help.title".localized, description: "menu.help.description".localized)
                }
            }
            .navigationTitle("menu.title".localized)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("menu.button.close".localized) {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct MenuRowView: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30, height: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    MenuView()
}