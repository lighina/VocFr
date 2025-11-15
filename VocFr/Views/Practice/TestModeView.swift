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

            Text("test.mode.title".localized)
                .font(.title)
                .fontWeight(.bold)

            Text("test.coming.soon".localized)
                .foregroundColor(.secondary)
        }
        .navigationTitle("test.title".localized)
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