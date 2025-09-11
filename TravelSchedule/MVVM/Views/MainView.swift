//
//  MainView.swift
//  TravelSchedule
//
//  Created by Наталья Черномырдина on 08.09.2025.

import SwiftUI

struct MainView: View {
    @State private var fromStation: Station?
    @State private var toStation: Station?
    @State private var navigationPath = NavigationPath()
    @State private var isSelectingFrom = true
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                Color.ypWhite
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    StoriesPlaceholderView()
                    
                    DirectionCardView(
                        fromStation: $fromStation,
                        toStation: $toStation,
                        onFromStationTapped: { showCitySelection(isFrom: true) },
                        onToStationTapped: { showCitySelection(isFrom: false) },
                        onSwapStations: swapStations
                    )
                    .padding(.top, 44)
                    .padding(.horizontal, 16)
                    
                    if isFindButtonEnabled {
                        FindButtonView(
                            fromStation: fromStation,
                            toStation: toStation
                        )
                        .padding(.top, 16)
                    }
                    
                    Spacer()
                }
            }
            .navigationDestination(for: StationNavigation.self) { destination in
                switch destination {
                case .citySelection:
                    CitySelectionView(
                        selectedStation: isSelectingFrom ? $fromStation : $toStation,
                        onStationSelected: { station in
                            navigationPath.append(StationNavigation.stationSelection(city: station.name))
                        }
                    )
                case .stationSelection(let city):
                    StationSelectionView(
                        selectedStation: isSelectingFrom ? $fromStation : $toStation,
                        city: city,
                        onStationSelected: { station in
                            let fullStationName = "\(city) (\(station.name))"
                            if isSelectingFrom {
                                fromStation = Station(name: fullStationName)
                            } else {
                                toStation = Station(name: fullStationName)
                            }
                            navigationPath.removeLast(navigationPath.count)
                        }
                    )
                }
            }
        }
    }
    
    // MARK: - Private Properties
    
    private var isFindButtonEnabled: Bool {
        fromStation != nil && toStation != nil
    }
    
    // MARK: - Private Methods
    
    private func showCitySelection(isFrom: Bool) {
        isSelectingFrom = isFrom
        navigationPath.append(StationNavigation.citySelection)
    }
    
    private func swapStations() {
        let temp = fromStation
        fromStation = toStation
        toStation = temp
    }
}

#Preview {
    MainView()
}
