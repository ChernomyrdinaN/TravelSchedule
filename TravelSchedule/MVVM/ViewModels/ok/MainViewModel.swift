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
    @Published var fromStation: Station?
    @Published var toStation: Station?
    @Published var showingError: ErrorModel.ErrorType?
    @Published var isLoading = false
    
    private let apiClient: APIClient
    
    init(apiClient: APIClient = DIContainer.shared.apiClient) {
        self.apiClient = apiClient
    }
    
    func loadInitialData() async {
    }
    
    func swapStations() {
        let temp = fromStation
        fromStation = toStation
        toStation = temp
    }
    
    var isFindButtonEnabled: Bool {
        fromStation != nil && toStation != nil && !isLoading
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
            date: todayYMD // ← ДОБАВЬ ДАТУ
        )
        
        return response.segments ?? []
    }
    
    private func getTodayYMD() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "Europe/Moscow")
        let today = Date()
        
        print("📅 REAL CURRENT DATE: \(formatter.string(from: today))")
        print("📅 REAL CURRENT YEAR: \(Calendar.current.component(.year, from: today))")
        
        return formatter.string(from: today)
    }
}
