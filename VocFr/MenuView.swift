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
                NavigationLink(destination: ProgressView()) {
                    MenuRowView(icon: "chart.line.uptrend.xyaxis", title: "进度", description: "查看学习进度")
                }
                
                NavigationLink(destination: SettingsView()) {
                    MenuRowView(icon: "gearshape", title: "设置", description: "应用设置和数据管理")
                }
                
                SwiftUI.Section {
                    MenuRowView(icon: "info.circle", title: "关于", description: "版本信息")
                    MenuRowView(icon: "questionmark.circle", title: "帮助", description: "使用帮助")
                }
            }
            .navigationTitle("菜单")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("关闭") {
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