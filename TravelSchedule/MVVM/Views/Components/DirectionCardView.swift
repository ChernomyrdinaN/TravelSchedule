//
//  DirectionCardView.swift
//  TravelSchedule
//
//  Created by Наталья Черномырдина on 08.09.2025.
//
//

import SwiftUI

struct DirectionCardView: View {
    // MARK: - Properties
    @Binding var fromStation: Station?
    @Binding var toStation: Station?
    @Binding var isShowingFromPicker: Bool
    @Binding var isShowingToPicker: Bool
    
    // MARK: - Body
    var body: some View {
        ZStack {
            Color.ypBlue
                .cornerRadius(20)
            
            HStack(spacing: 16) {
                VStack(spacing: 16) {
                    stationField(text: fromStation?.name ?? "Откуда",
                               isPlaceholder: fromStation == nil,
                               action: { isShowingFromPicker = true })
                    
                    stationField(text: toStation?.name ?? "Куда",
                               isPlaceholder: toStation == nil,
                               action: { isShowingToPicker = true })
                }
                .frame(maxWidth: .infinity, maxHeight: 96)
                .background(.white)
                .cornerRadius(20)
                .padding(.leading, 16)
                .padding(.vertical, 16)
                
                Button(action: swapStations) {
                    Image("ButtonСhange")
                        .resizable()
                        .frame(width: 36, height: 36)
                        .foregroundColor(.white)
                }
                .padding(.trailing, 16)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 128)
    }
    
    // MARK: - Private Methods
    private func swapStations() {
        let temp = fromStation
        fromStation = toStation
        toStation = temp
    }
    
    private func stationField(text: String, isPlaceholder: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(text)
                    .font(.system(size: 17, weight: .regular))
                    .kerning(-0.41)
                    .foregroundColor(isPlaceholder ? .ypGray : .ypBlack)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .frame(height: 20)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
