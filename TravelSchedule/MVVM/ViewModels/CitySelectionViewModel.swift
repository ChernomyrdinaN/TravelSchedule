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
        } else {
            await useMockData()
        }
    }
    
    func filterCities(searchText: String) {
        if searchText.isEmpty {
            filteredCities = cities
        } else {
            filteredCities = cities.filter { city in
                city.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    func hideError() {
        showingError = nil
    }
    
    private func checkAPIAvailability() async -> Bool {
        do {
            _ = try await apiClient.getAllStations()
            return true
        } catch {
            return false
        }
    }
    
    private func loadCitiesFromAPI() async {
        do {
            let apiCities = try await apiClient.getRussianCities()
            
            if apiCities.isEmpty {
                await useMockData()
            } else {
                cities = apiCities
                filteredCities = cities
                isUsingMockData = false
            }
            
        } catch {
            await useMockData()
        }
    }
    
    private func useMockData() async {
        cities = Station.mockData
        filteredCities = cities
        isUsingMockData = true
        
        if !cities.isEmpty {
            showingError = .serverError
        }
    }
}
