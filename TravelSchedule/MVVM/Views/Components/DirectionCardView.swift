//
//  DirectionCardView.swift
//  TravelSchedule
//
//  Created by Наталья Черномырдина on 08.09.2025.
//

import SwiftUI

struct DirectionCardView: View {
    @Binding var fromStation: Station?
    @Binding var toStation: Station?
    let onFromStationTapped: () -> Void
    let onToStationTapped: () -> Void
    let onSwapStations: () -> Void
    
    // MARK: - Body
    var body: some View {
        ZStack {
            Color.ypBlue
                .cornerRadius(20)
            
            HStack(spacing: 16) {
                VStack(spacing: .zero) {
                    stationField(
                        text: fromStation?.name ?? "Откуда",
                        isPlaceholder: fromStation == nil,
                        action: onFromStationTapped
                    )
                    
                    stationField(
                        text: toStation?.name ?? "Куда",
                        isPlaceholder: toStation == nil,
                        action: onToStationTapped
                    )
                }
                .background(Color.ypWhiteUniversal)
                .cornerRadius(20)
                .padding(.leading, 16)
                .padding(.vertical, 16)
                
                Button(action: onSwapStations) {
                    Image("ButtonСhange")
                        .resizable()
                        .frame(width: 36, height: 36)
                        .foregroundColor(.ypWhiteUniversal)
                }
                .padding(.trailing, 16)
            }
        }
        .frame(height: 128)
    }
    
    // MARK: - Private Methods
    private func stationField(text: String, isPlaceholder: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(text)
                    .font(.system(size: 17, weight: .regular))
                    .kerning(-0.41)
                    .foregroundColor(isPlaceholder ? .ypGrayUniversal: .ypBlackUniversal)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                
                Spacer()
            }
            .frame(height: 48)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
#Preview {
    DirectionCardView(
        fromStation: .constant(Station(name: "Москва (Курский вокзал)")),
        toStation: .constant(Station(name: "Санкт-Петербург (Балтийский вокзал)")),
        onFromStationTapped: {},
        onToStationTapped: {},
        onSwapStations: {}
    )
}
