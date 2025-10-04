//
//  MainView.swift
//  TravelSchedule
//
//  Created by Наталья Черномырдина on 08.09.2025.
//

import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = MainViewModel()
    @State private var navigationPath = NavigationPath()
    @State private var isSelectingFrom = true
    @State private var filter = CarrierFilter()
    
    // MARK: - Body
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                Color.ypWhite
                    .ignoresSafeArea()
                
                if let errorType = viewModel.showingError {
                    ErrorView(errorModel: errorType == .noInternet ? .error1 : .error2)
                } else {
                    VStack(spacing: .zero) {
                        StoriesView()
                        
                        DirectionCardView(
                            fromStation: $viewModel.fromStation,
                            toStation: $viewModel.toStation,
                            onFromStationTapped: { showCitySelection(isFrom: true) },
                            onToStationTapped: { showCitySelection(isFrom: false) },
                            onSwapStations: viewModel.swapStations
                        )
                        .padding(.top, 44)
                        .padding(.horizontal, 16)
                        
                        if viewModel.isFindButtonEnabled {
                            FindButtonView(
                                fromStation: viewModel.fromStation,
                                toStation: viewModel.toStation,
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
                        selectedStation: isSelectingFrom ? $viewModel.fromStation : $viewModel.toStation,
                        onStationSelected: { station in
                            navigationPath.append(StationNavigation.stationSelection(city: station.name))
                        }
                    )
                case .stationSelection(let city):
                    StationSelectionView(
                        selectedStation: isSelectingFrom ? $viewModel.fromStation : $viewModel.toStation,
                        city: city,
                        onStationSelected: { station in
                            let fullStationName = "\(city) (\(station.name))"
                            if isSelectingFrom {
                                viewModel.fromStation = Station(name: fullStationName)
                            } else {
                                viewModel.toStation = Station(name: fullStationName)
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
            .task {
                await viewModel.loadInitialData()
            }
        }
    }
    
    // MARK: - Private Methods
    private func showCitySelection(isFrom: Bool) {
        isSelectingFrom = isFrom
        navigationPath.append(StationNavigation.citySelection)
    }
    
    private func showCarrierList() {
        filter = CarrierFilter()
        guard let from = viewModel.fromStation?.name,
              let to = viewModel.toStation?.name else { return }
        navigationPath.append(StationNavigation.carrierList(from: from, to: to))
    }
}

// MARK: - Preview
#Preview {
    MainView()
}
