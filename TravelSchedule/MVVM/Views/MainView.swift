//
//  MainView.swift
//  TravelSchedule
//
//  Created by Наталья Черномырдина on 08.09.2025.

import SwiftUI

struct MainView: View {
    @State private var fromStation: Station?
    @State private var toStation: Station?
    @State private var isShowingFromPicker = false
    @State private var isShowingToPicker = false
    
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
                    .padding(.top, 16)
                    .padding(.horizontal, 16)
                    
                    FindButtonView(
                        fromStation: fromStation,
                        toStation: toStation
                    )
                    .padding(.top, 16)
                    
                    Spacer()
                }
            }
            .fullScreenCover(isPresented: $isShowingFromPicker) {
                            CitySelectionView(
                                selectedStation: $fromStation,
                                onStationSelected: { station in
                                    fromStation = station
                                }
                            )
                        }
                        .fullScreenCover(isPresented: $isShowingToPicker) {
                            CitySelectionView(
                                selectedStation: $toStation,
                                onStationSelected: { station in
                                    toStation = station
                                }
                            )
                        }
                    }
                }
            }

#Preview {
    MainView()
}
