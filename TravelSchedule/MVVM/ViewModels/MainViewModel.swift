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
    
    // MARK: - Init
    init() {
        self.apiClient = DIContainer.shared.apiClient
    }
    
    // MARK: - Public Methods
    func loadInitialData() async {
    }

    func swapStations() {
        let temp = fromStation
        fromStation = toStation
        toStation = temp
    }
    
    var isFindButtonEnabled: Bool {
        fromStation != nil && toStation != nil
    }

    func showError(_ errorType: ErrorModel.ErrorType) {
        showingError = errorType
    }
    
    func hideError() {
        showingError = nil
    }
    
    // MARK: - Network Methods
    func getAllStations() async throws -> Components.Schemas.AllStationsResponse {
        return try await apiClient.getAllStations()
    }
    
    func getScheduleBetweenStations(
        from: String,
        to: String,
        date: String? = nil
    ) async throws -> Components.Schemas.Segments {
        return try await apiClient.getScheduleBetweenStations(
            from: from,
            to: to,
            date: date
        )
    }
}
