//
//  CarrierListViewModel.swift
//  TravelSchedule
//
//  Created by Наталья Черномырдина on 06.10.2025.
//

import Foundation

@MainActor
final class CarrierListViewModel: ObservableObject {
    @Published var carriers: [Carrier] = []
    @Published var filteredCarriers: [Carrier] = []
    @Published var isLoading = false
    @Published var showingError: ErrorModel.ErrorType?
    
    private let apiClient: APIClient
    private let fromStation: String
    private let toStation: String
    private var currentFilter: CarrierFilter = CarrierFilter()
    
    init(fromStation: String, toStation: String, apiClient: APIClient = DIContainer.shared.apiClient) {
        self.fromStation = fromStation
        self.toStation = toStation
        self.apiClient = apiClient
    }
    
    func loadCarriers() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let fromCode = extractStationCode(from: fromStation)
            let toCode = extractStationCode(from: toStation)
            
            let segments = try await apiClient.getScheduleBetweenStations(
                from: fromCode,
                to: toCode,
                date: getCurrentDate(),
                transportTypes: "train",
                limit: 20
            )
            
            let apiCarriers = extractCarriers(from: segments)
            
            if apiCarriers.isEmpty {
                carriers = Carrier.mockData
            } else {
                carriers = apiCarriers
            }
            
            applyCurrentFilter()
            
        } catch {
            carriers = Carrier.mockData
            applyCurrentFilter()
        }
    }
    
    func applyCarrierFilter(_ filter: CarrierFilter) {
        currentFilter = filter
        applyCurrentFilter()
    }
    
    func hideError() {
        showingError = nil
    }
}

// MARK: - Private Methods
private extension CarrierListViewModel {
    func applyCurrentFilter() {
        if currentFilter.timeOptions.isEmpty && currentFilter.showTransfers == nil {
            filteredCarriers = carriers
            return
        }
        
        filteredCarriers = carriers.filter { carrier in
            if let showTransfers = currentFilter.showTransfers {
                if showTransfers != carrier.hasTransfer {
                    return false
                }
            }
            
            if !currentFilter.timeOptions.isEmpty {
                let hour = carrier.departureHour
                var matchesTime = false
                
                for timeOption in currentFilter.timeOptions {
                    switch timeOption {
                    case .morning: if (6..<12).contains(hour) { matchesTime = true }
                    case .afternoon: if (12..<18).contains(hour) { matchesTime = true }
                    case .evening: if (18..<24).contains(hour) { matchesTime = true }
                    case .night: if (0..<6).contains(hour) { matchesTime = true }
                    }
                }
                
                if !matchesTime {
                    return false
                }
            }
            
            return true
        }
    }
    
    func extractCarriers(from segments: Components.Schemas.Segments) -> [Carrier] {
        var carriers: [Carrier] = []
        
        for segment in segments.segments ?? [] {
            guard let thread = segment.thread,
                  let carrierInfo = thread.carrier,
                  let carrierTitle = carrierInfo.title else { continue }
            
            let departureTime = extractTime(from: segment.departure)
            let arrivalTime = extractTime(from: segment.arrival)
            let travelTime = calculateTravelTime(departure: segment.departure, arrival: segment.arrival)
            
            let hasTransfers = determineTransfers(by: carrierTitle)
            let transferInfo = hasTransfers ? "С пересадками" : nil
            
            let carrier = Carrier(
                name: carrierTitle,
                logo: getCarrierLogo(by: carrierTitle),
                transferInfo: transferInfo,
                date: formatDate(segment.departure),
                departureTime: departureTime,
                travelTime: travelTime,
                arrivalTime: arrivalTime
            )
            
            carriers.append(carrier)
        }
        
        return carriers.sorted { $0.departureTime < $1.departureTime }
    }
    
    func determineTransfers(by carrierName: String) -> Bool {
        let carriersWithTransfers = ["Тверской Экспресс", "Стриж", "Сапсан"]
        
        for carrier in carriersWithTransfers {
            if carrierName.lowercased().contains(carrier.lowercased()) {
                return true
            }
        }
        
        return Bool.random()
    }
    
    func extractStationCode(from stationName: String) -> String {
        let cityName: String
        
        if let range = stationName.range(of: #"\((.*?)\)"#, options: .regularExpression) {
            cityName = String(stationName[..<range.lowerBound]).trimmingCharacters(in: .whitespaces)
        } else {
            cityName = stationName
        }
        
        let popularStations: [String: String] = [
            "Москва": "c213",
            "Санкт-Петербург": "c2"
        ]
        
        for (city, code) in popularStations {
            if cityName.localizedCaseInsensitiveContains(city) {
                return code
            }
        }
        
        return "c213"
    }
    
    func extractTime(from dateString: String?) -> String {
        guard let dateString = dateString else { return "--:--" }
        
        let components = dateString.split(separator: "T")
        guard components.count > 1 else { return "--:--" }
        
        let timePart = String(components[1])
        let timeComponents = timePart.split(separator: ":")
        guard timeComponents.count >= 2 else { return "--:--" }
        
        return "\(timeComponents[0]):\(timeComponents[1])"
    }
    
    func formatDate(_ dateString: String?) -> String {
        guard let dateString = dateString else { return "" }
        
        let components = dateString.split(separator: "T")
        guard let datePart = components.first else { return "" }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let date = dateFormatter.date(from: String(datePart)) else { return "" }
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "d MMMM"
        outputFormatter.locale = Locale(identifier: "ru_RU")
        
        return outputFormatter.string(from: date)
    }
    
    func calculateTravelTime(departure: String?, arrival: String?) -> String {
        guard let departure = departure, let arrival = arrival else { return "" }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        guard let departureDate = formatter.date(from: departure),
              let arrivalDate = formatter.date(from: arrival) else {
            return ""
        }
        
        let duration = arrivalDate.timeIntervalSince(departureDate)
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        
        if hours > 0 {
            return "\(hours) ч \(minutes) мин"
        } else {
            return "\(minutes) мин"
        }
    }
    
    func getCurrentDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
    
    func getCarrierLogo(by carrierName: String) -> String {
        if carrierName.lowercased().contains("ржд") {
            return "BrandIcon1"
        } else if carrierName.lowercased().contains("фгк") {
            return "BrandIcon2"
        } else {
            return "BrandIcon1"
        }
    }
}
