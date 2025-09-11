//
//  StoriesPlaceholderView.swift
//  TravelSchedule
//
//  Created by Наталья Черномырдина on 08.09.2025.
//

import SwiftUI

// MARK: - Model
struct StoryItem: Identifiable {
    let id = UUID()
    let image: String
    let text: String
}

// MARK: - Main View
struct StoriesPlaceholderView: View {
    // MARK: - Properties
    private let stories = [
        StoryItem(image: "ilBig1", text: "Москва"),
        StoryItem(image: "ilBig2", text: "Санкт-Петербург"),
        StoryItem(image: "ilBig3", text: "Сочи"),
        StoryItem(image: "ilBig4", text: "Казань"),
        StoryItem(image: "ilBig5", text: "Екатеринбург"),
        StoryItem(image: "ilBig6", text: "Нижний Новгород")
    ]
    
    @State private var selectedStoryIndex = 0
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 24)
            
            storiesScrollView
        }
        .background(.ypWhite)
    }
    
    // MARK: - Subviews
    private var storiesScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Array(stories.enumerated()), id: \.element.id) { index, story in
                    StoryCard(
                        imageName: story.image,
                        text: story.text,
                        isActive: index == selectedStoryIndex,
                        onTap: { selectedStoryIndex = index }
                    )
                }
            }
            .padding(.horizontal, 16)
        }
        .background(.ypWhite)
    }
}

// MARK: - Story Card Component
struct StoryCard: View {
    
    // MARK: - Properties
    let imageName: String
    let text: String
    let isActive: Bool
    let onTap: () -> Void
    
    @State private var isPressed = false
    
    // MARK: - Body
    var body: some View {
        Button(action: onTap) {
            cardContent
                .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(pressGesture)
    }
    
    // MARK: - Subviews
    private var cardContent: some View {
        ZStack(alignment: .bottom) {
            backgroundImage
            textOverlay
        }
        .frame(width: 92, height: 148)
    }
    
    private var backgroundImage: some View {
        Image(imageName)
            .resizable()
            .scaledToFill()
            .frame(width: 92, height: 140)
            .cornerRadius(16)
            .overlay(borderOverlay)
            .opacity(isActive ? 1.0 : 0.5)
    }
    
    private var borderOverlay: some View {
        RoundedRectangle(cornerRadius: 16)
            .stroke(
                isActive ? .ypBlue : Color.clear,
                lineWidth: isActive ? 4 : 0
            )
    }
    
    private var textOverlay: some View {
        VStack {
            Spacer()
            HStack {
                Text(text)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.ypWhite1)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .frame(width: 76, height: 45, alignment: .leading)
                    .padding(.leading, 8)
                Spacer()
            }
            .padding(.bottom, 8)
        }
        .frame(height: 140)
    }
    
    // MARK: - Gesture
    private var pressGesture: some Gesture {
        LongPressGesture(minimumDuration: 0.1)
            .onChanged { _ in isPressed = true }
            .onEnded { _ in isPressed = false }
    }
}

#Preview {
    StoriesPlaceholderView()
}
