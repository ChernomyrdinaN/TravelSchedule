//
//  MainView.swift
//  TravelSchedule
//
//  Created by Наталья Черномырдина on 08.09.2025.

// Пока оставляем логику здесь, при подключении API перенесем в ViewModel
// @StateObject private var viewModel = MainViewModel()

import SwiftUI

struct MainView: View {
    @State private var fromStation: Station?
    @State private var toStation: Station?
    @State private var navigationPath = NavigationPath()
    @State private var isSelectingFrom = true
    @State private var filter = CarrierFilter()
    @State private var showingError: ErrorModel.ErrorType? = nil // Добавляем состояние для ошибки
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                Color.ypWhite
                    .ignoresSafeArea()
                
                // Условное отображение: ошибка или основной контент
                if let errorType = showingError {
                    ErrorView(errorModel: errorType == .noInternet ? .error1 : .error2)
                } else {
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
                        navigationPath: $navigationPath
                    )
                    
                case .filters:
                    FilterView(filter: $filter, applyFilters: applyFilters)
                }
            }
            .onAppear {
                // Для тестирования - показываем ошибку через 2 секунды
                testErrorDisplay()
            }
        }
    }
    
    // MARK: - Методы для тестирования
    private func testErrorDisplay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            //showError(.noInternet)
            //showError(.serverError)
        }
    }
    
    private var filterButton: some View {
        NavigationLink(value: StationNavigation.filters) {
            Text("Фильтры")
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(.ypBlue)
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
    
    private func showCarrierList() {
        guard let from = fromStation?.name, let to = toStation?.name else { return }
        navigationPath.append(StationNavigation.carrierList(from: from, to: to))
    }
    
    private func swapStations() {
        let temp = fromStation
        fromStation = toStation
        toStation = temp
    }
    
    private func applyFilters() {
        navigationPath.removeLast()
    }
    
    // MARK: - Методы для управления ошибками
    func showError(_ errorType: ErrorModel.ErrorType) {
        showingError = errorType
    }
    
    func hideError() {
        showingError = nil
    }
}

#Preview {
    MainView()
}
