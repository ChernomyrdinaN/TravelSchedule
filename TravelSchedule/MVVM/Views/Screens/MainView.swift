//
//  MainView.swift
//  TravelSchedule
//
//  Created by Наталья Черномырдина on 08.09.2025.
//

import SwiftUI

struct MainView: View {
    @State private var fromStation: Station?
    @State private var toStation: Station?
    @State private var navigationPath = NavigationPath()
    @State private var isSelectingFrom = true
    @State private var filter = CarrierFilter()
    @State private var showingError: ErrorModel.ErrorType? = nil
    
    // MARK: - Body
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                Color.ypWhite
                    .ignoresSafeArea()
                
                if let errorType = showingError {
                    ErrorView(errorModel: errorType == .noInternet ? .error1 : .error2)
                } else {
                    VStack(spacing: .zero) {
                        StoriesView()
                        
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
                                toStation: toStation,
                                onFindTapped: showCarrierList
                            )
                            .padding(.top, 16)
                        }
                        
                        Spacer()
                    }
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
                    
                case .carrierList(let from, let to):
                    CarrierListView(
                        fromStation: from,
                        toStation: to,
                        navigationPath: $navigationPath,
                        filter: $filter
                    )
                    
                case .filters:
                    FilterView(
                        filter: $filter,
                        applyFilters: {}
                    )
                }
            }
            .onAppear {
                testErrorDisplay()
            }
        }
    }
    
    // MARK: - Private Methods
    private func testErrorDisplay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            // Для тестирования ошибок:
            // showError(.noInternet)
            // showError(.serverError)
        }
    }
    
    private var isFindButtonEnabled: Bool {
        fromStation != nil && toStation != nil
    }
    
    private func showCitySelection(isFrom: Bool) {
        isSelectingFrom = isFrom
        navigationPath.append(StationNavigation.citySelection)
    }
    
    private func showCarrierList() {
        filter = CarrierFilter()
        guard let from = fromStation?.name, let to = toStation?.name else { return }
        navigationPath.append(StationNavigation.carrierList(from: from, to: to))
    }
    
    private func swapStations() {
        let temp = fromStation
        fromStation = toStation
        toStation = temp
    }
    
    private func showError(_ errorType: ErrorModel.ErrorType) {
        showingError = errorType
    }
    
    private func hideError() {
        showingError = nil
    }
}

// MARK: - Preview
#Preview {
    MainView()
}
