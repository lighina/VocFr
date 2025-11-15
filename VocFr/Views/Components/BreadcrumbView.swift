//
//  BreadcrumbView.swift
//  VocFr
//
//  Created by Claude on 15/11/2025.
//

import SwiftUI

/// Breadcrumb navigation component
struct BreadcrumbView: View {
    let items: [BreadcrumbItem]

    var body: some View {
        HStack(spacing: 4) {
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                if index > 0 {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                }

                if let action = item.action {
                    Button(action: action) {
                        Text(item.title)
                            .font(.system(size: 13, weight: index == items.count - 1 ? .semibold : .regular))
                            .foregroundColor(index == items.count - 1 ? .primary : .secondary)
                    }
                } else {
                    Text(item.title)
                        .font(.system(size: 13, weight: index == items.count - 1 ? .semibold : .regular))
                        .foregroundColor(index == items.count - 1 ? .primary : .secondary)
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }
}

struct BreadcrumbItem {
    let title: String
    let action: (() -> Void)?

    init(title: String, action: (() -> Void)? = nil) {
        self.title = title
        self.action = action
    }
}
