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

    /// Trigger to pop to UniteDetailView (Section List) - increment to navigate there
    @Published var popToUniteDetailTrigger: Int = 0

    /// Trigger to pop to SectionDetailView (Word List) - increment to navigate there
    @Published var popToSectionDetailTrigger: Int = 0

    /// Navigate to root (MainAppView)
    func popToRoot() {
        popToRootTrigger += 1
    }

    /// Navigate to UniteDetailView (Section List)
    func popToUniteDetail() {
        popToUniteDetailTrigger += 1
    }

    /// Navigate to SectionDetailView (Word List)
    func popToSectionDetail() {
        popToSectionDetailTrigger += 1
    }
}
