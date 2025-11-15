//
//  NavigationDestination.swift
//  VocFr
//
//  Created by Claude on 15/11/2025.
//

import Foundation

/// Navigation destinations for NavigationStack
enum NavigationDestination: Hashable {
    case unite(Unite)
    case section(Section)
    case word(section: Section, wordIndex: Int)
}
