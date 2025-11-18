//
//  MainAppView.swift
//  VocFr
//
//  Created by Junfeng Wang on 22/09/2025.
//

import SwiftUI
import SwiftData

struct MainAppView: View {
    @State private var showingMenu = false
    @Query private var allAchievements: [Achievement]

    /// Check if there are any claimable achievements
    private var hasClaimableAchievements: Bool {
        allAchievements.contains { $0.isReadyToClaim }
    }

    var body: some View {
        VStack(spacing: 30) {
            // 欢迎信息
            VStack(spacing: 10) {
                Text("main.select.mode".localized)
                    .font(.title)
                    .fontWeight(.bold)

                Text("main.select.mode.subtitle".localized)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top)

            Spacer()

            // 四个学习选项（堆积式布局）
            VStack(spacing: 20) {
                // 学习模式
                NavigationLink(destination: UnitsView()) {
                    MainModeButton(
                        icon: "book.closed",
                        title: "main.study.title".localized,
                        description: "main.study.description".localized,
                        color: .blue
                    )
                }

                // 答题模式
                NavigationLink(destination: TestModeView()) {
                    MainModeButton(
                        icon: "doc.text",
                        title: "main.test.title".localized,
                        description: "main.test.description".localized,
                        color: .green
                    )
                }

                // 游戏模式
                NavigationLink(destination: GameModeView()) {
                    MainModeButton(
                        icon: "gamecontroller",
                        title: "main.game.title".localized,
                        description: "main.game.description".localized,
                        color: .purple
                    )
                }

                // 故事书模式
                NavigationLink(destination: StorybooksListView()) {
                    MainModeButton(
                        icon: "books.vertical",
                        title: "main.storybooks.title".localized,
                        description: "main.storybooks.description".localized,
                        color: .orange
                    )
                }
            }
            .padding(.horizontal)

            Spacer()
        }
        .toolbar {
            #if os(iOS)
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { showingMenu = true }) {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "line.3.horizontal")
                            .font(.title2)

                        // Red badge for claimable achievements
                        if hasClaimableAchievements {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 8, height: 8)
                                .offset(x: 6, y: -6)
                        }
                    }
                }
            }
            #else
            ToolbarItem(placement: .automatic) {
                Button(action: { showingMenu = true }) {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "line.3.horizontal")
                            .font(.title2)

                        // Red badge for claimable achievements
                        if hasClaimableAchievements {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 8, height: 8)
                                .offset(x: 6, y: -6)
                        }
                    }
                }
            }
            #endif
        }
        .sheet(isPresented: $showingMenu) {
            MenuView()
        }
    }
}

// 主要模式按钮组件
struct MainModeButton: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    var isDisabled: Bool = false
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(isDisabled ? .gray : color)
                .frame(width: 50, height: 50)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(isDisabled ? .gray : .primary)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(isDisabled ? .gray : .secondary)
            }
            
            Spacer()
            
            if !isDisabled {
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(isDisabled ? Color.gray.opacity(0.1) : color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(isDisabled ? Color.gray.opacity(0.3) : color.opacity(0.3), lineWidth: 1)
                )
        )
        .disabled(isDisabled)
    }
}

#Preview {
    MainAppView()
}