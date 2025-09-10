//
//  MainView.swift
//  TravelSchedule
//
//  Created by Наталья Черномырдина on 08.09.2025.

import SwiftUI

struct MainView: View {
    // MARK: - Properties
    @State private var fromStation: Station?
    @State private var toStation: Station?
    @State private var isShowingFromPicker = false
    @State private var isShowingToPicker = false
    @State private var isShowingStationPicker = false
    @State private var selectedCity: String = ""
    @State private var isSelectingFrom: Bool = true
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                Color.ypWhite
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    StoriesPlaceholderView()
                    
                    DirectionCardView(
                        fromStation: $fromStation,
                        toStation: $toStation,
                        isShowingFromPicker: $isShowingFromPicker,
                        isShowingToPicker: $isShowingToPicker
                    )
                    .padding(.top, 44)
                    .padding(.horizontal, 16)
                    
                    FindButtonView(
                        fromStation: fromStation,
                        toStation: toStation
                    )
                    .padding(.top, 16)
                    
                    Spacer()
                }
            }
            // MARK: - Full Screen Covers
            .fullScreenCover(isPresented: $isShowingFromPicker) {
                CitySelectionView(
                    selectedStation: $fromStation,
                    onStationSelected: { station in
                        selectedCity = station.name
                        isShowingFromPicker = false
                        isShowingStationPicker = true
                        isSelectingFrom = true
                    }
                )
            }
            .fullScreenCover(isPresented: $isShowingToPicker) {
                CitySelectionView(
                    selectedStation: $toStation,
                    onStationSelected: { station in
                        selectedCity = station.name
                        isShowingToPicker = false
                        isShowingStationPicker = true
                        isSelectingFrom = false
                    }
                )
            }
            .fullScreenCover(isPresented: $isShowingStationPicker) {
                StationSelectionView(
                    selectedStation: isSelectingFrom ? $fromStation : $toStation,
                    city: selectedCity,
                    onStationSelected: { station in
                        if isSelectingFrom {
                            fromStation = Station(name: "\(selectedCity) (\(station.name))")
                        } else {
                            toStation = Station(name: "\(selectedCity) (\(station.name))")
                        }
                        isShowingStationPicker = false
                    }
                )
            }
        }
    }
}

// MARK: - Preview
#Preview {
    MainView()
}
