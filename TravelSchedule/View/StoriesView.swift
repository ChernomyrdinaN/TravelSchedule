//
//  StoriesView.swift
//  TravelSchedule
//
//  Created by Наталья Черномырдина on 08.09.2025.
//

import SwiftUI

private struct StorySelection: Identifiable { let id: Int }

// MARK: - Stories View
struct StoriesView: View {
    @State private var stories = MockData.stories
    @State private var selectedStory: StorySelection? = nil
    
    var body: some View {
        VStack(spacing: .zero) {
            Spacer()
                .frame(height: 24)
            
            storiesScrollView
        }
        .background(.ypWhite)
        .fullScreenCover(item: $selectedStory) { selection in
            FullscreenStoriesView(
                stories: $stories,
                initialStoryIndex: selection.id
            )
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
                        text: story.slides.first?.text ?? "Новое путешествие",
                        isViewed: story.isViewed,
                        onTap: {
                            selectedStory = StorySelection(id: index)
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
