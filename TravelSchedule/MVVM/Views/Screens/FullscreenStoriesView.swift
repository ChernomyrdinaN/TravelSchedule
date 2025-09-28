//
//  FullscreenStoriesView.swift
//  TravelSchedule
//
//  Created by Наталья Черномырдина on 28.09.2025.
//

import SwiftUI
import Combine

struct FullscreenStoriesView: View {
    @Binding var stories: [StoryItem]
    let initialStoryIndex: Int
    
    @Environment(\.dismiss) private var dismiss
    @State private var currentStoryIndex: Int
    @State private var currentSlideIndex: Int = 0
    @State private var progress: CGFloat = 0.0
    @State private var timer: Timer.TimerPublisher
    @State private var cancellable: Cancellable?
    
    // MARK: - Configuration
    private let timerInterval: TimeInterval = 0.05
    private let slideDuration: TimeInterval = 5.0
    private var progressPerTick: CGFloat {
        return CGFloat(timerInterval / slideDuration)
    }
    
    private var currentStory: StoryItem {
        stories[currentStoryIndex]
    }
    
    private var currentSlides: [StorySlide] {
        currentStory.slides
    }
    
    private var currentSlide: StorySlide {
        currentSlides[currentSlideIndex]
    }
    
    // MARK: - Init
    init(stories: Binding<[StoryItem]>, initialStoryIndex: Int) {
        self._stories = stories
        self.initialStoryIndex = initialStoryIndex
        self._currentStoryIndex = State(initialValue: initialStoryIndex)
        self.timer = Timer.publish(every: timerInterval, on: .main, in: .common)
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            TabView(selection: $currentStoryIndex) {
                ForEach(Array(stories.enumerated()), id: \.offset) { index, story in
                    TabView(selection: $currentSlideIndex) {
                        ForEach(Array(story.slides.enumerated()), id: \.offset) { slideIndex, slide in
                            SingleStoryView(slide: slide, onClose: { dismiss() })
                                .tag(slideIndex)
                        }
                    }
                    .cornerRadius(40)
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .onChange(of: currentStoryIndex) { oldValue, newValue in
                handleStoryChange()
            }
            
            VStack {
                HStack(spacing: 4) {
                    ForEach(0..<currentSlides.count, id: \.self) { index in
                        ProgressBarSegment(
                            isActive: index == currentSlideIndex,
                            progress: index == currentSlideIndex ? progress : (index < currentSlideIndex ? 1.0 : 0.0)
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 60)
                Spacer()
            }
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.black.opacity(0.7))
                            .clipShape(Circle())
                    }
                    .padding(.top, 60)
                    .padding(.trailing, 20)
                }
                Spacer()
            }
        }
        .onAppear {
            startTimer()
            markCurrentStoryAsViewed()
        }
        .onDisappear {
            stopTimer()
        }
        .onReceive(timer) { _ in
            handleTimerTick()
        }
        .onTapGesture {
            nextSlide()
        }
        .gesture(
            DragGesture()
                .onEnded { value in
                    handleDragGesture(value)
                }
        )
        .onChange(of: currentSlideIndex) { oldValue, newValue in
            resetProgress()
        }
    }
    
    // MARK: - Timer Management
    private func startTimer() {
        timer = Timer.publish(every: timerInterval, on: .main, in: .common)
        cancellable = timer.connect()
    }
    
    private func stopTimer() {
        cancellable?.cancel()
    }
    
    private func handleTimerTick() {
        progress += progressPerTick
        
        if progress >= 1.0 {
            nextSlide()
        }
    }
    
    private func resetProgress() {
        progress = 0.0
    }
    
    // MARK: - Navigation
    private func nextSlide() {
        if currentSlideIndex < currentSlides.count - 1 {
            currentSlideIndex += 1
            resetProgress()
        } else {
            nextStory()
        }
    }
    
    private func previousSlide() {
        if currentSlideIndex > 0 {
            currentSlideIndex -= 1
            resetProgress()
        } else {
            previousStory()
        }
    }
    
    private func nextStory() {
        if currentStoryIndex < stories.count - 1 {
            currentStoryIndex += 1
        } else {
            dismiss()
        }
    }
    
    private func previousStory() {
        if currentStoryIndex > 0 {
            currentStoryIndex -= 1
        }
    }
    
    private func handleStoryChange() {
        currentSlideIndex = 0
        resetProgress()
        stopTimer()
        startTimer()
        markCurrentStoryAsViewed()
    }
    
    private func handleDragGesture(_ value: DragGesture.Value) {
        let horizontalTranslation = value.translation.width
        
        if horizontalTranslation < -50 {
            nextSlide()
        } else if horizontalTranslation > 50 {
            previousSlide()
        }
    }
    
    // MARK: - Story State
    private func markCurrentStoryAsViewed() {
        if currentStoryIndex < stories.count {
            stories[currentStoryIndex].isViewed = true
        }
    }
}

// MARK: - SingleStoryView
struct SingleStoryView: View {
    let slide: StorySlide
    let onClose: () -> Void
    
    var body: some View {
        ZStack {
            Image(slide.image)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                VStack(alignment: .leading, spacing: 16) {
                    Text(slide.text)
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(slide.subtitle)
                        .font(.system(size: 20, weight: .regular))
                        .foregroundColor(.white)
                        .lineLimit(3)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(width: 343, alignment: .leading)
                .padding(.bottom, 40)
                .padding(.horizontal, 16)
            }
        }
    }
}

// MARK: - ProgressBarSegment
struct ProgressBarSegment: View {
    let isActive: Bool
    let progress: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 2)
                    .frame(width: geometry.size.width, height: 4)
                    .foregroundColor(.white.opacity(0.3))
                
                RoundedRectangle(cornerRadius: 2)
                    .frame(width: progress * geometry.size.width, height: 4)
                    .foregroundColor(.ypBlueUniversal)
                    .animation(.linear(duration: 0.05), value: progress)
            }
        }
        .frame(height: 4)
    }
}

// MARK: - Preview
#Preview {
    FullscreenStoriesView(
        stories: .constant([
            StoryItem(slides: [
                StorySlide(image: "ilPreview1", text: "Text Text Text", subtitle: "Text Text Text Text"),
                StorySlide(image: "ilBig2", text: "Text Text Text", subtitle: "Text Text Text Text")
            ]),
            StoryItem(slides: [
                StorySlide(image: "ilPreview2", text: "Text Text Text", subtitle: "Text Text Text Text"),
                StorySlide(image: "ilBig4", text: "Text Text Text", subtitle: "Text Text Text Text")
            ])
        ]),
        initialStoryIndex: 0
    )
}
