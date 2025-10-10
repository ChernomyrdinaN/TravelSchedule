//
//  StoriesView.swift
//  TravelSchedule
//
//  Created by Наталья Черномырдина on 08.09.2025.
//

//
//  StoriesView.swift
//  TravelSchedule
//
//  Created by Наталья Черномырдина on 08.09.2025.
//

import SwiftUI

private struct StorySelection: Identifiable { let id: Int }

struct StoriesView: View {
    @State private var stories = [
        StoryItem(slides: [
            StorySlide(image: "ilPreview1", text: "Откройте новые горизонты", subtitle: "Путешествия расширяют кругозор и дарят незабываемые впечатления. Отправляйтесь в путь и откройте для себя удивительные места"),
            StorySlide(image: "ilBig2", text: "Планируйте с комфортом", subtitle: "Создайте идеальный маршрут и наслаждайтесь каждой минутой путешествия. Всё что нужно для поездки в одном приложении")
        ]),
        StoryItem(slides: [
            StorySlide(image: "ilPreview2", text: "Города и культуры", subtitle: "Каждый город имеет свою уникальную атмосферу и историю. Погрузитесь в местный колорит и традиции"),
            StorySlide(image: "ilBig4", text: "Архитектура и искусство", subtitle: "Знакомьтесь с архитектурными шедеврами и культурным наследием разных городов и стран")
        ]),
        StoryItem(slides: [
            StorySlide(image: "ilPreview3", text: "Природа и пейзажи", subtitle: "От величественных гор до бескрайних морей - природа дарит вдохновение и умиротворение"),
            StorySlide(image: "ilBig6", text: "Активный отдых", subtitle: "Пешие прогулки, экскурсии и приключения - выбирайте свой формат путешествия")
        ]),
        StoryItem(slides: [
            StorySlide(image: "ilPreview4", text: "Культурный обмен", subtitle: "Путешествия объединяют людей разных национальностей и культур. Откройте для себя новый взгляд на мир"),
            StorySlide(image: "ilBig8", text: "Местная кухня", subtitle: "Попробуйте традиционные блюда и узнайте кулинарные секреты разных регионов")
        ]),
        StoryItem(slides: [
            StorySlide(image: "ilPreview5", text: "Исторические места", subtitle: "Посетите значимые исторические объекты и почувствуйте связь времен и поколений"),
            StorySlide(image: "ilBig10", text: "Современные достопримечательности", subtitle: "Откройте для себя современную архитектуру и новые культурные пространства")
        ]),
        StoryItem(slides: [
            StorySlide(image: "ilPreview6", text: "Сезонные путешествия", subtitle: "Каждое время года по-своему раскрывает красоту мест. Путешествуйте в любое время года"),
            StorySlide(image: "ilBig12", text: "Фотографии и воспоминания", subtitle: "Сохраняйте лучшие моменты путешествий в фотографиях и ярких воспоминаниях")
        ]),
        StoryItem(slides: [
            StorySlide(image: "ilPreview7", text: "Комфорт в пути", subtitle: "Современные средства передвижения делают путешествия удобными и доступными для всех"),
            StorySlide(image: "ilBig14", text: "Путешествия с близкими", subtitle: "Создавайте общие воспоминания с семьей и друзьями в новых местах")
        ]),
        StoryItem(slides: [
            StorySlide(image: "ilPreview8", text: "Открытия каждый день", subtitle: "Даже в знакомых местах можно найти что-то новое и необычное. Будьте открыты к приключениям"),
            StorySlide(image: "ilBig16", text: "Вдохновение для новых поездок", subtitle: "Каждое путешествие рождает идеи для следующих маршрутов и открытий")
        ]),
        StoryItem(slides: [
            StorySlide(image: "ilPreview9", text: "Мир без границ", subtitle: "Путешествия стирают границы и помогают лучше понимать друг друга. Отправляйтесь в путь к новым знакомствам"),
            StorySlide(image: "ilBig18", text: "Возвращение домой", subtitle: "Самое приятное в путешествиях - возвращаться домой с багажом впечатлений и планами на будущее")
        ])
    ]
    
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
