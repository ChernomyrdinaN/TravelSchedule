//
//  CitySelectionViewModel.swift
//  TravelSchedule
//
//  Created by Наталья Черномырдина on 05.10.2025.
//

import Foundation

@MainActor
final class CitySelectionViewModel: ObservableObject {
    @Published var cities: [Station] = []
    @Published var filteredCities: [Station] = []
    @Published var isLoading = false
    @Published var showingError: ErrorModel.ErrorType?
    @Published var isUsingMockData = true
    
    private let apiClient: APIClient
    
    init(apiClient: APIClient = DIContainer.shared.apiClient) {
        self.apiClient = apiClient
    }
    
    func loadCities() async {
        isLoading = true
        defer { isLoading = false }
        
        let isAPIAvailable = await checkAPIAvailability()
        
        if isAPIAvailable {
            await loadCitiesFromAPI()
        }
    }
    
    func filterCities(searchText: String) {
            filteredCities = searchText.isEmpty ? cities : cities.filter { city in
               city.name.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    func hideError() {
        showingError = nil
    }
}

// MARK: - Private Methods
private extension CitySelectionViewModel {
    func checkAPIAvailability() async -> Bool {
        do {
            _ = try await apiClient.getAllStations()
            return true
        } catch {
            return false
        }
    }
    
    func loadCitiesFromAPI() async {
        do {
            let apiCities = try await apiClient.getRussianCities()
            
            if apiCities.isEmpty {
                print("Empty cities list")
            } else {
                cities = apiCities
                filteredCities = cities
                isUsingMockData = false
            }
            
        } catch {
            print("Empty cities list")
        }
    }
    
    
}
