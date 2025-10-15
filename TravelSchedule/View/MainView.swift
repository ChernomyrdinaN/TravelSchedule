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

    @EnvironmentObject private var overlay: AppOverlayCenter
    
    // MARK: - Body
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                Color.ypWhite
                    .ignoresSafeArea()

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

                if overlay.isInternetDown {
                    ErrorOverlayView(model: .noInternet)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .zIndex(10)
                }
            }
            .navigationDestination(for: NavigationModels.self) { destination in
                switch destination {
                case .citySelection:
                    CitySelectionView(
                        selectedStation: isSelectingFrom ? $viewModel.fromStation : $viewModel.toStation,
                        onStationSelected: { station in
                            navigationPath.append(
                                NavigationModels.stationSelection(city: station.name)
                            )
                        }
                    )
                
                case .stationSelection(let city):
                    StationSelectionView(
                        selectedStation: isSelectingFrom ? $viewModel.fromStation : $viewModel.toStation,
                        city: city,
                        onStationSelected: { station in
                            let pretty = "\(city) (\(station.name))"
                            let updated = Station(
                                name: pretty,
                                code: station.code,
                                transportType: station.transportType
                            )
                            if isSelectingFrom {
                                viewModel.fromStation = updated
                            } else {
                                viewModel.toStation = updated
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
            .onReceive(NotificationCenter.default.publisher(for: .resetMainNavigation)) { _ in
                navigationPath = NavigationPath()
            }
        }
        .onAppear {
            overlay.clearServerError()
        }
    }
    
    // MARK: - Private Methods
    private func showCitySelection(isFrom: Bool) {
        isSelectingFrom = isFrom
        navigationPath.append(NavigationModels.citySelection)
    }
    
    private func showCarrierList() {
        filter = CarrierFilter()
        guard let from = viewModel.fromStation,
              let to = viewModel.toStation else { return }

        if from.code == to.code {
            NotificationCenter.default.post(
                name: .serverErrorOccurred,
                object: nil,
                userInfo: ["code": 400]
            )
            return
        }

        navigationPath.append(NavigationModels.carrierList(from: from, to: to))
    }
}

// MARK: - Preview
#Preview {
    MainView()
        .environmentObject(DIContainer.shared.overlayCenter)
}
