//
//  MainViewModel.swift
//  TravelSchedule
//
//  Created by Наталья Черномырдина on 13.09.2025.
//

import Foundation
import SwiftUI

@MainActor
final class MainViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var fromStation: Station?
    @Published var toStation: Station?
    @Published var showingError: ErrorModel.ErrorType?
    @Published var isLoading = false
    
    // MARK: - Private Properties
    private let apiClient: APIClient
    
    // MARK: - Initialization
    init(apiClient: APIClient = DIContainer.shared.apiClient) {
        self.apiClient = apiClient
    }
}

// MARK: - Public Methods
extension MainViewModel {
    func loadInitialData() async {
    }
    
    func swapStations() {
        let temp = fromStation
        fromStation = toStation
        toStation = temp
    }
    
    func showError(_ errorType: ErrorModel.ErrorType) {
        showingError = errorType
    }
    
    func hideError() {
        showingError = nil
    }
    
    func validateStations() -> Bool {
        guard fromStation != nil, toStation != nil else {
            showError(.serverError)
            return false
        }
        
        return true
    }
    
    func getAllStations() async throws -> Components.Schemas.AllStationsResponse {
        return try await apiClient.getAllStations()
    }
    
    func getScheduleBetweenStations(
        from: Station,
        to: Station
    ) async throws -> [Components.Schemas.Segment] {
        let todayYMD = getTodayYMD()
        
        let response = try await apiClient.getScheduleBetweenStations(
            from: from.code,
            to: to.code,
            date: todayYMD
        )
        
        return response.segments ?? []
    }
}

// MARK: - Computed Properties
extension MainViewModel {
    var isFindButtonEnabled: Bool {
        fromStation != nil && toStation != nil && !isLoading
    }
}

// MARK: - Private Methods
private extension MainViewModel {
    func getTodayYMD() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "Europe/Moscow")
        return formatter.string(from: Date())
    }
}
