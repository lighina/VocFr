//
//  QuickNavigationMenu.swift
//  VocFr
//
//  Created by Claude on 15/11/2025.
//

import SwiftUI

/// Quick navigation menu for jumping to different levels
struct QuickNavigationMenu: View {
    let items: [QuickNavItem]

    var body: some View {
        Menu {
            ForEach(items) { item in
                Button(action: item.action) {
                    Label(item.title, systemImage: item.icon)
                }
            }
        } label: {
            Image(systemName: "line.3.horizontal")
                .imageScale(.large)
        }
    }
}

struct QuickNavItem: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let action: () -> Void
}
