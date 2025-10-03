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
    @State private var didInitialize: Bool = false
    
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
                            SingleStoryView(slide: slide)
                                .tag(slideIndex)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .onChange(of: currentStoryIndex) { oldValue, newValue in
                if !didInitialize {
                    if newValue == initialStoryIndex {
                        didInitialize = true
                    }
                    return
                }
                handleStoryChange()
            }
            
            VStack {
                Spacer()
                
                VStack(alignment: .leading, spacing: 16) {
                    Text(currentSlide.text)
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .truncationMode(.tail)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(currentSlide.subtitle)
                        .font(.system(size: 20, weight: .regular))
                        .foregroundColor(.white)
                        .lineLimit(3)
                        .truncationMode(.tail)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.bottom, 40)
                .padding(.horizontal, 16)
            }
            
            VStack {
                HStack(spacing: 6) {
                    ForEach(0..<currentSlides.count, id: \.self) { index in
                        ProgressBarSegment(
                            isActive: index == currentSlideIndex,
                            progress: index == currentSlideIndex ? progress : (index < currentSlideIndex ? 1.0 : 0.0)
                        )
                    }
                }
                .padding(.top, 28)
                .padding(.horizontal, 12)
                Spacer()
            }
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.ypWhiteUniversal)
                            .frame(width: 24, height: 24)
                            .background(Color.ypBlackUniversal)
                            .clipShape(Circle())
                    }
                    .padding(.top, 50)
                    .padding(.trailing, 12)
                }
                Spacer()
            }
        }
        .onAppear {
            startTimer()
            markStoryAsViewed(at: initialStoryIndex)
            didInitialize = (currentStoryIndex == initialStoryIndex)
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
        .cornerRadius(40)
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
        markStoryAsViewed(at: currentStoryIndex)
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
    private func markStoryAsViewed(at index: Int) {
        guard stories.indices.contains(index) else { return }
        stories[index].isViewed = true
    }
}

// MARK: - SingleStoryView
struct SingleStoryView: View {
    let slide: StorySlide
    
    var body: some View {
        Image(slide.image)
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
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
                    .frame(width: geometry.size.width, height: 6)
                    .foregroundColor(.ypWhiteUniversal)
                
                RoundedRectangle(cornerRadius: 2)
                    .frame(width: progress * geometry.size.width, height: 6)
                    .foregroundColor(.ypBlueUniversal)
                    .animation(.linear(duration: 0.05), value: progress)
            }
        }
        .frame(height: 6)
    }
}

// MARK: - Preview
#Preview {
    FullscreenStoriesView(
        stories: .constant([
            StoryItem(slides: [
                StorySlide(image: "ilPreview1",
                           text: "Очень длинный заголовок который не помещается в две строки и должен обрезаться с многоточием",
                           subtitle: "Очень длинный подзаголовок который содержит много текста и не помещается в три строки поэтому должен обрезаться с многоточием в конце текста"),
                StorySlide(image: "ilBig2",
                           text: "Очень длинный заголовок который не помещается в две строки и должен обрезаться с многоточием",
                           subtitle: "чень длинный подзаголовок который содержит много текста и не помещается в три строки поэтому должен обрезаться с многоточием в конце текста")
            ])
        ]),
        initialStoryIndex: 0
    )
}
