//
//  MainViewModel.swift
//  TravelSchedule
//
//  Created by Наталья Черномырдина on 13.09.2025.
//

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
        return fromStation != nil && toStation != nil
    }
}

// MARK: - Computed Properties
extension MainViewModel {
    var isFindButtonEnabled: Bool {
        fromStation != nil && toStation != nil && !isLoading
    }
}
