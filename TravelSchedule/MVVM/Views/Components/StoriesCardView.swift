//
//  StoriesCardView.swift
//  TravelSchedule
//
//  Created by Наталья Черномырдина on 28.09.2025.
//

import SwiftUI

struct StoriesCardView: View {
    let imageName: String
    let text: String
    let isViewed: Bool
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
    
    // MARK: - Private Views
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
            .opacity(isViewed ? 0.5 : 1.0)
    }
    
    private var borderOverlay: some View {
        RoundedRectangle(cornerRadius: 16)
            .stroke(
                isViewed ? Color.clear : .ypBlueUniversal,
                lineWidth: isViewed ? 0 : 4
            )
    }
    
    private var textOverlay: some View {
        VStack {
            Spacer()
            HStack {
                Text(text)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.ypWhiteUniversal)
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
    
    // MARK: - Gestures
    private var pressGesture: some Gesture {
        LongPressGesture(minimumDuration: 0.1)
            .onChanged { _ in isPressed = true }
            .onEnded { _ in isPressed = false }
    }
}

// MARK: - Preview
#Preview {
    VStack {
        Text("Непросмотренные (яркие + обводка)")
        HStack {
            StoriesCardView(
                imageName: "ilBig1",
                text: "Москва",
                isViewed: false,
                onTap: {}
            )
            StoriesCardView(
                imageName: "ilBig2",
                text: "Санкт-Петербург",
                isViewed: false,
                onTap: {}
            )
        }
        
        Text("Просмотренные (блеклые без обводки)")
        HStack {
            StoriesCardView(
                imageName: "ilBig3",
                text: "Сочи",
                isViewed: true,
                onTap: {}
            )
            StoriesCardView(
                imageName: "ilBig4",
                text: "Казань",
                isViewed: true,
                onTap: {}
            )
        }
    }
}
