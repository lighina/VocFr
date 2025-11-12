//
//  TestModeView.swift
//  VocFr
//
//  Created by Junfeng Wang on 22/09/2025.
//

import SwiftUI

// 测试模式视图（占位符）
struct TestModeView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "questionmark.circle")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            Text("答题模式")
                .font(.title)
                .fontWeight(.bold)
            
            Text("测试功能正在开发中")
                .foregroundColor(.secondary)
        }
        .navigationTitle("答题")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

#Preview {
    NavigationView {
        TestModeView()
    }
}