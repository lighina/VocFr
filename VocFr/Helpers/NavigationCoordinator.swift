//
//  NavigationCoordinator.swift
//  VocFr
//
//  Created by Claude on 16/11/2025.
//

import SwiftUI
import Combine

/// Simple coordinator to signal navigation resets
class NavigationCoordinator: ObservableObject {
    /// Trigger to pop to root - increment this to navigate home
    @Published var popToRootTrigger: Int = 0

    /// Navigate to root (home)
    func popToRoot() {
        popToRootTrigger += 1
    }
}
