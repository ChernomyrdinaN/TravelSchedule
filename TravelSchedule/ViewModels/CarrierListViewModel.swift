//
//  CarrierListViewModel.swift
//  TravelSchedule
//
//  Created by Наталья Черномырдина on 04.10.2025.
//

import Foundation

@MainActor
final class CarrierListViewModel: ObservableObject {
    @Published var carriers: [Carrier] = []
    @Published var filteredCarriers: [Carrier] = []
    @Published var isLoading = false
    @Published var loadError: ErrorModel?
    @Published var hasEmptyResults = false
    
    let fromStation: Station
    let toStation: Station
    let apiClient: APIClient
    
    private let allowedTransportTypes: Set<String> = ["train", "suburban"]
    private var currentFilter: CarrierFilter = CarrierFilter()
    
    // MARK: - Init
    init(fromStation: Station, toStation: Station, apiClient: APIClient) {
        self.fromStation = fromStation
        self.toStation = toStation
        self.apiClient = apiClient
    }
}

// MARK: - Public Methods
extension CarrierListViewModel {
    func loadCarriers() async {
        isLoading = true
        loadError = nil
        hasEmptyResults = false
        defer { isLoading = false }
        
        do {
            let response = try await apiClient.getScheduleBetweenStations(
                from: fromStation.code,
                to: toStation.code,
                date: todayYMD,
                transportTypes: Array(allowedTransportTypes),
                limit: 50
            )
            
            let allSegments = response.segments ?? []
            
            if allSegments.isEmpty {
                self.hasEmptyResults = true
                self.carriers = []
                self.filteredCarriers = []
                return
            }
            
            let transportFiltered = allSegments.filter { seg in
                guard let type = seg.thread?.transport_type?.lowercased() else { return true }
                return allowedTransportTypes.contains(type)
            }
            
            if transportFiltered.isEmpty {
                self.hasEmptyResults = true
                self.carriers = []
                self.filteredCarriers = []
                return
            }
            
            let dedupedSegments = dedupeSegments(transportFiltered)
            
            if dedupedSegments.isEmpty {
                self.hasEmptyResults = true
                self.carriers = []
                self.filteredCarriers = []
                return
            }
            
            self.carriers = try await mapSegmentsToCarriers(dedupedSegments)
            
            if self.carriers.isEmpty {
                self.hasEmptyResults = true
                self.filteredCarriers = []
            } else {
                self.hasEmptyResults = false
                applyCurrentFilters()
            }
            
        } catch {
            handleError(error)
        }
    }
    
    func applyFilters(_ filter: CarrierFilter) {
        currentFilter = filter
        applyCurrentFilters()
    }
}

// MARK: - Private Methods
private extension CarrierListViewModel {
    func applyCurrentFilters() {
        var result = carriers
        
        if !currentFilter.timeOptions.isEmpty {
            result = result.filter { carrier in
                let hour = carrier.departureHour
                return currentFilter.timeOptions.contains { timeOption in
                    isTimeInRange(hour: hour, timeOption: timeOption)
                }
            }
        }
        
        if let showTransfers = currentFilter.showTransfers {
            if showTransfers == false {
                result = result.filter { !$0.hasTransfer }
            }
        }

        self.filteredCarriers = result
        self.hasEmptyResults = result.isEmpty
    }
    
    func handleError(_ error: Error) {
        let errorModel: ErrorModel
        
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost, .cannotConnectToHost:
                errorModel = .noInternet
            default:
                errorModel = .serverError
            }
        }
        else if let apiError = error as? APIError {
            switch apiError {
            case .serverError:
                errorModel = .serverError
            case .badRequest, .invalidRequest, .invalidStationCode:
                errorModel = .serverError
            case .unauthorized:
                errorModel = .serverError
            case .notFound:
                self.hasEmptyResults = true
                self.carriers = []
                self.filteredCarriers = []
                self.loadError = nil
                return
            case .networkError(let underlyingError):
                if let urlError = underlyingError as? URLError {
                    switch urlError.code {
                    case .notConnectedToInternet, .networkConnectionLost:
                        errorModel = .noInternet
                    default:
                        errorModel = .serverError
                    }
                } else {
                    errorModel = .serverError
                }
            default:
                errorModel = .serverError
            }
        }
        else {
            errorModel = .serverError
        }
        
        self.loadError = errorModel
        self.carriers = []
        self.filteredCarriers = []
        self.hasEmptyResults = false
    }
    
    func isTimeInRange(hour: Int, timeOption: CarrierFilter.TimeOption) -> Bool {
        switch timeOption {
        case .morning: return (6..<12).contains(hour)
        case .afternoon: return (12..<18).contains(hour)
        case .evening: return (18..<24).contains(hour)
        case .night: return hour < 6
        }
    }
    
    func segmentHasTransfers(_ seg: Components.Schemas.Segment) -> Bool {
        return Bool.random()
    }
    
    func dedupeSegments(_ segments: [Components.Schemas.Segment]) -> [Components.Schemas.Segment] {
        var seen = Set<String>()
        var out: [Components.Schemas.Segment] = []
        out.reserveCapacity(segments.count)
        
        for seg in segments {
            let dep = seg.departure ?? ""
            let t = seg.thread
            let uid = t?.uid ?? ""
            let num = t?.number ?? ""
            let title = t?.title ?? ""
            
            let keys = [
                "UID|\(uid)|\(dep)",
                "NUM|\(num)|\(dep)",
                "TTL|\(title)|\(dep)"
            ]
            
            if keys.first(where: { seen.contains($0) }) == nil {
                keys.forEach { seen.insert($0) }
                out.append(seg)
            }
        }
        return out
    }
    
    func mapSegmentsToCarriers(_ segments: [Components.Schemas.Segment]) async throws -> [Carrier] {
        var carriers: [Carrier] = []
        
        for seg in segments {
            let departureISO = seg.departure ?? ""
            let arrivalISO   = seg.arrival ?? ""
            let (depDate, depTime) = splitISO(departureISO)
            let (_, arrTime)       = splitISO(arrivalISO)
            
            let formattedDate = formatDateToRu(depDate) ?? depDate
            
            let hasTransfer = segmentHasTransfers(seg)
            let transferInfo: String? = hasTransfer ? "С пересадкой" : nil
            
            let thread = seg.thread
            let carr   = thread?.carrier
            
            let title = carr?.title ?? thread?.title ?? "Перевозчик"
            let logo  = (carr?.logo ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            let carrierCode = extractCarrierCode(from: carr, title: title)
            
            let travelTime: String = {
                if let dur = seg.duration, dur > 0 { return humanizeDuration(seconds: dur) }
                return durationFromISO(departureISO: departureISO, arrivalISO: arrivalISO)
            }()
            
            let carrier = Carrier(
                name: title,
                logo: logo,
                transferInfo: transferInfo,
                date: formattedDate,
                departureTime: depTime,
                travelTime: travelTime,
                arrivalTime: arrTime,
                code: carrierCode
            )
            carriers.append(carrier)
        }
        
        return carriers
    }
    
    func extractCarrierCode(from carrier: Components.Schemas.Carrier?, title: String) -> String {
        if let code = carrier?.code {
            return "\(code)"
        }
        
        if let iataCode = carrier?.codes?.iata {
            return iataCode
        }
        
        return title
    }
    
    func splitISO(_ iso: String) -> (String, String) {
        guard iso.count >= 16, let tIndex = iso.firstIndex(of: "T") else { return ("", "") }
        let datePart = String(iso[..<tIndex])
        let timeStart = iso.index(after: tIndex)
        let timePart = String(iso[timeStart...].prefix(5))
        return (datePart, timePart)
    }
    
    func humanizeDuration(seconds: Int?) -> String {
        guard let seconds, seconds > 0 else { return "" }
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        if h > 0, m > 0 { return "\(h)ч \(m)м" }
        if h > 0 { return "\(h)ч" }
        if m > 0 { return "\(m)м" }
        return "\(seconds)с"
    }
    
    func durationFromISO(departureISO: String, arrivalISO: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let depDate = formatter.date(from: departureISO),
              let arrDate = formatter.date(from: arrivalISO) else {
            return "2ч 30м"
        }
        
        let duration = Int(arrDate.timeIntervalSince(depDate))
        return humanizeDuration(seconds: duration)
    }
    
    func formatDateToRu(_ ymd: String) -> String? {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        guard let date = inputFormatter.date(from: ymd) else { return nil }
        
        let outputFormatter = DateFormatter()
        outputFormatter.locale = Locale(identifier: "ru_RU")
        outputFormatter.dateFormat = "d MMMM"
        
        return outputFormatter.string(from: date)
    }
    
    var todayYMD: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}
