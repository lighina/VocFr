//
//  TestModeView.swift
//  VocFr
//
//  Created by Junfeng Wang on 22/09/2025.
//

import SwiftUI

// 测试模式视图（占位符）
struct TestModeView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "questionmark.circle")
                .font(.system(size: 80))
                .foregroundColor(.green)

            Text("test.mode.title".localized)
                .font(.title)
                .fontWeight(.bold)

            Text("test.coming.soon".localized)
                .foregroundColor(.secondary)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .navigationTitle("test.title".localized)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("common.done".localized)
                            .font(.system(size: 16))
                    }
                }
            }
        }
        .gesture(
            DragGesture(minimumDistance: 20)
                .onEnded { value in
                    // Swipe right from left edge to go back
                    if value.startLocation.x < 50 && value.translation.width > 100 {
                        dismiss()
                    }
                }
        )
    }
}

#Preview {
    NavigationView {
        TestModeView()
    }
}