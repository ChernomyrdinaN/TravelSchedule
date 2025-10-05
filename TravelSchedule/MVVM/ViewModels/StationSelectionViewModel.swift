//
//  StationSelectionViewModel.swift
//  TravelSchedule
//
//  Created by Наталья Черномырдина on 05.10.2025.
//

import Foundation

@MainActor
final class StationSelectionViewModel: ObservableObject {
    @Published var stations: [Station] = []
    @Published var filteredStations: [Station] = []
    @Published var isLoading = false
    @Published var showingError: ErrorModel.ErrorType?
    @Published var isUsingMockData = true
    
    private let apiClient: APIClient
    private let city: String
    
    init(city: String, apiClient: APIClient = DIContainer.shared.apiClient) {
        self.city = city
        self.apiClient = apiClient
    }
    
    func loadStations() async {
        isLoading = true
        defer { isLoading = false }
        
        let isAPIAvailable = await checkAPIAvailability()
        
        if isAPIAvailable {
            await loadStationsFromAPI()
        } else {
            await useMockData()
        }
    }
    
    func filterStations(searchText: String) {
        if searchText.isEmpty {
            filteredStations = stations
        } else {
            filteredStations = stations.filter { station in
                station.name.localizedCaseInsensitiveContains(searchText)
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
    
    private func loadStationsFromAPI() async {
        do {
            let apiStations = try await apiClient.getStationsForCity(city)
            
            if apiStations.isEmpty {
                await useMockData()
            } else {
                stations = apiStations
                filteredStations = stations
                isUsingMockData = false
            }
            
        } catch {
            await useMockData()
        }
    }
    
    private func useMockData() async {
        stations = Station.mockStations(for: city)
        filteredStations = stations
        isUsingMockData = true
        
        if !stations.isEmpty {
            showingError = .serverError
        }
    }
}
