//
//  FilterViewModel.swift
//  TravelSchedule
//
//  Created by Наталья Черномырдина on 06.10.2025.
//

import Foundation

@MainActor
final class FilterViewModel: ObservableObject {
    @Published var filter: CarrierFilter
    @Published var isLoading = false
    
    private let onFilterChanged: (CarrierFilter) -> Void
    
    init(initialFilter: CarrierFilter = CarrierFilter(), onFilterChanged: @escaping (CarrierFilter) -> Void = { _ in }) {
        self.filter = initialFilter
        self.onFilterChanged = onFilterChanged
    }
    
    func toggleTimeOption(_ option: CarrierFilter.TimeOption) {
        if filter.timeOptions.contains(option) {
            filter.timeOptions.removeAll { $0 == option }
        } else {
            filter.timeOptions.append(option)
        }
        applyFilterImmediately()
    }
    
    func setTransferFilter(_ showTransfers: Bool?) {
        filter.showTransfers = showTransfers
        applyFilterImmediately()
    }
    
    func applyFilter() {
        onFilterChanged(filter)
    }
    
    var hasSelectedFilters: Bool {
        !filter.timeOptions.isEmpty && filter.showTransfers != nil
    }
    
    // MARK: - Private Methods
    private func applyFilterImmediately() {
        if hasSelectedFilters {
            applyFilter()
        }
    }
}
