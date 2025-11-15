//
//  ToolbarButtonStyle.swift
//  VocFr
//
//  Created by Claude on 15/11/2025.
//

import SwiftUI

/// Standard toolbar button style for consistent sizing
struct ToolbarIconButton: View {
    let icon: String
    let isActive: Bool
    let activeColor: Color
    let action: () -> Void

    init(
        icon: String,
        isActive: Bool = false,
        activeColor: Color = .blue,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.isActive = isActive
        self.activeColor = activeColor
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(isActive ? activeColor : .secondary)
        }
    }
}

/// Extension for consistent button sizing
extension View {
    func toolbarButtonSize() -> some View {
        self.frame(width: 32, height: 32)
    }
}
