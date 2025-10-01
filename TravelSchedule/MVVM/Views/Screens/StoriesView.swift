//
//  StoriesView.swift
//  TravelSchedule
//
//  Created by Наталья Черномырдина on 08.09.2025.
//

import SwiftUI

struct StoriesView: View {
    @State private var stories = [
        StoryItem(slides: [
            StorySlide(image: "ilPreview1", text: "Text Text Text Text Text Text Text Text Text Text", subtitle: "Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text"),
            StorySlide(image: "ilBig2", text: "Text Text Text Text Text Text Text Text Text Text", subtitle: "Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text")
        ]),
        StoryItem(slides: [
            StorySlide(image: "ilPreview2", text: "Text Text Text Text Text Text Text Text Text Text", subtitle: "Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text"),
            StorySlide(image: "ilBig4", text: "Text Text Text Text Text Text Text Text Text Text", subtitle: "Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text")
        ]),
        StoryItem(slides: [
            StorySlide(image: "ilPreview3", text: "Text Text Text Text Text Text Text Text Text Text", subtitle: "Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text"),
            StorySlide(image: "ilBig6", text: "Text Text Text Text Text Text Text Text Text Text", subtitle: "Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text")
        ]),
        StoryItem(slides: [
            StorySlide(image: "ilPreview4", text: "Text Text Text Text Text Text Text Text Text Text", subtitle: "Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text"),
            StorySlide(image: "ilBig8", text: "Text Text Text Text Text Text Text Text Text Text", subtitle: "Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text")
        ]),
        StoryItem(slides: [
            StorySlide(image: "ilPreview5", text: "Text Text Text Text Text Text Text Text Text Text", subtitle: "Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text"),
            StorySlide(image: "ilBig10", text: "Text Text Text Text Text Text Text Text Text Text", subtitle: "Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text")
        ]),
        StoryItem(slides: [
            StorySlide(image: "ilPreview6", text: "Text Text Text Text Text Text Text Text Text Text", subtitle: "Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text"),
            StorySlide(image: "ilBig12", text: "Text Text Text Text Text Text Text Text Text Text", subtitle: "Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text")
        ]),
        StoryItem(slides: [
            StorySlide(image: "ilPreview7", text: "Text Text Text Text Text Text Text Text Text Text", subtitle: "Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text"),
            StorySlide(image: "ilBig14", text: "Text Text Text Text Text Text Text Text Text Text", subtitle: "Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text")
        ]),
        StoryItem(slides: [
            StorySlide(image: "ilPreview8", text: "Text Text Text Text Text Text Text Text Text Text", subtitle: "Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text"),
            StorySlide(image: "ilBig16", text: "Text Text Text Text Text Text Text Text Text Text", subtitle: "Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text")
        ]),
        StoryItem(slides: [
            StorySlide(image: "ilPreview9", text: "Text Text Text Text Text Text Text Text Text Text", subtitle: "Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text"),
            StorySlide(image: "ilBig18", text: "Text Text Text Text Text Text Text Text Text Text", subtitle: "Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text")
        ])
    ]
    
    @State private var selectedStoryIndex = 0
    @State private var showFullscreenStories = false
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: .zero) {
            Spacer()
                .frame(height: 24)
            
            storiesScrollView
        }
        .background(.ypWhite)
        .fullScreenCover(isPresented: $showFullscreenStories) {
            FullscreenStoriesView(
                stories: $stories,
                initialStoryIndex: selectedStoryIndex
            )
            .id(selectedStoryIndex)
            .preferredColorScheme(.dark)
        }
    }
    
    // MARK: - Private Views
    private var storiesScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Array(stories.enumerated()), id: \.element.id) { index, story in
                    StoriesCardView(
                        imageName: story.slides.first?.image ?? "ilPreview1",
                        text: "Text Text Text Text Text Text Text Text Text Text",
                        isViewed: story.isViewed,
                        onTap: {
                            selectedStoryIndex = index
                            showFullscreenStories = true
                        }
                    )
                }
            }
            .padding(.horizontal, 16)
        }
        .background(.ypWhite)
    }
}

// MARK: - Preview
#Preview {
    StoriesView()
}
