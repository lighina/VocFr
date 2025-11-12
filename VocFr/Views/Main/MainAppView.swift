//
//  MainAppView.swift
//  VocFr
//
//  Created by Junfeng Wang on 22/09/2025.
//

import SwiftUI

struct MainAppView: View {
    @State private var showingMenu = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // 欢迎信息
                VStack(spacing: 10) {
                    Text("选择学习模式")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("选择适合您的学习方式")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top)
                
                Spacer()
                
                // 三个学习选项（堆积式布局）
                VStack(spacing: 20) {
                    // 学习模式
                    NavigationLink(destination: UnitsView()) {
                        MainModeButton(
                            icon: "book.closed",
                            title: "学习",
                            description: "系统化学习法语词汇",
                            color: .blue
                        )
                    }
                    
                    // 答题模式
                    NavigationLink(destination: TestModeView()) {
                        MainModeButton(
                            icon: "questionmark.circle",
                            title: "答题",
                            description: "测试您的法语水平",
                            color: .green
                        )
                    }
                    
                    // 游戏模式
                    MainModeButton(
                        icon: "gamecontroller",
                        title: "游戏",
                        description: "敬请期待",
                        color: .purple,
                        isDisabled: true
                    )
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("法语学习")
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showingMenu = true }) {
                        Image(systemName: "line.3.horizontal")
                            .font(.title2)
                    }
                }
                #else
                ToolbarItem(placement: .automatic) {
                    Button(action: { showingMenu = true }) {
                        Image(systemName: "line.3.horizontal")
                            .font(.title2)
                    }
                }
                #endif
            }
            .sheet(isPresented: $showingMenu) {
                MenuView()
            }
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