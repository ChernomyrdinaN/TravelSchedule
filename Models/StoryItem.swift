//
//  StoryItem.swift
//  TravelSchedule
//
//  Created by Наталья Черномырдина on 28.09.2025.
//

import SwiftUI

// MARK: - StorySlide
struct StorySlide: Identifiable, Sendable {
    let id = UUID()
    let image: String
    let text: String
    let subtitle: String
}

// MARK: - StoryItem
struct StoryItem: Identifiable {
    let id = UUID()
    let slides: [StorySlide]
    var isViewed: Bool = false
}
