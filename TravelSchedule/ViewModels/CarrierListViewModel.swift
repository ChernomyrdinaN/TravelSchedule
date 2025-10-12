//
//  CarrierListViewModel.swift
//  TravelSchedule
//
//  Created by Наталья Черномырдина on 04.10.2025.
//

import Foundation

@MainActor
final class CarrierListViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var carriers: [Carrier] = []
    @Published var filteredCarriers: [Carrier] = []
    @Published var isLoading = false
    @Published var loadError: ErrorModel?
    
    // MARK: - Public Properties
    let fromStation: Station
    let toStation: Station
    
    // MARK: - Private Properties
    private let apiClient: APIClient
    private let allowedTransportTypes: Set<String> = ["train", "suburban"]
    private var currentFilter: CarrierFilter = CarrierFilter()
    
    // MARK: - Initialization
    init(fromStation: Station, toStation: Station, apiClient: APIClient) {
        self.fromStation = fromStation
        self.toStation = toStation
        self.apiClient = apiClient
    }
    
    // MARK: - Public Methods
    func loadCarriers() async {
        isLoading = true
        loadError = nil
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
                self.loadError = .error1
                self.carriers = []
                self.filteredCarriers = []
                return
            }
            
            let transportFiltered = allSegments.filter { seg in
                guard let type = seg.thread?.transport_type?.lowercased() else { return true }
                return allowedTransportTypes.contains(type)
            }
            
            if transportFiltered.isEmpty {
                self.loadError = .error1
                self.carriers = []
                self.filteredCarriers = []
                return
            }
            
            let dedupedSegments = dedupeSegments(transportFiltered)
            
            if dedupedSegments.isEmpty {
                self.loadError = .error1
                self.carriers = []
                self.filteredCarriers = []
                return
            }
            
            self.carriers = mapSegmentsToCarriers(dedupedSegments)
            
            if self.carriers.isEmpty {
                self.loadError = .error1
                self.filteredCarriers = []
                return
            }
            
            applyCurrentFilters()
            
        } catch {
            let errorModel: ErrorModel
            
            if let urlError = error as? URLError {
                switch urlError.code {
                case .notConnectedToInternet, .networkConnectionLost:
                    errorModel = .error2
                default:
                    errorModel = .error2
                }
            } else {
                errorModel = .error2
            }
            
            self.loadError = errorModel
            self.carriers = []
            self.filteredCarriers = []
        }
    }
    
    func applyFilters(_ filter: CarrierFilter) {
        currentFilter = filter
        applyCurrentFilters()
    }
    
    // MARK: - Private Methods
    private func applyCurrentFilters() {
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
    }
    
    private func isTimeInRange(hour: Int, timeOption: CarrierFilter.TimeOption) -> Bool {
        switch timeOption {
        case .morning:
            return (6..<12).contains(hour)
        case .afternoon:
            return (12..<18).contains(hour)
        case .evening:
            return (18..<24).contains(hour)
        case .night:
            return hour < 6
        }
    }
    
    private func segmentHasTransfers(_ seg: Components.Schemas.Segment) -> Bool {
        return Bool.random()
    }
    
    private func dedupeSegments(_ segments: [Components.Schemas.Segment]) -> [Components.Schemas.Segment] {
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
    
    private func mapSegmentsToCarriers(_ segments: [Components.Schemas.Segment]) -> [Carrier] {
        let result = segments.compactMap { seg in
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
            
            let travelTime: String = {
                if let dur = seg.duration, dur > 0 { return humanizeDuration(seconds: dur) }
                return durationFromISO(departureISO: departureISO, arrivalISO: arrivalISO)
            }()
            
            return Carrier(
                name: title,
                logo: logo,
                transferInfo: transferInfo,
                date: formattedDate,
                departureTime: depTime,
                travelTime: travelTime,
                arrivalTime: arrTime
            )
        }
        
        return result
    }
    
    private func splitISO(_ iso: String) -> (String, String) {
        guard iso.count >= 16, let tIndex = iso.firstIndex(of: "T") else { return ("", "") }
        let datePart = String(iso[..<tIndex])
        let timeStart = iso.index(after: tIndex)
        let timePart = String(iso[timeStart...].prefix(5))
        return (datePart, timePart)
    }
    
    private func humanizeDuration(seconds: Int?) -> String {
        guard let seconds, seconds > 0 else { return "" }
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        if h > 0, m > 0 { return "\(h)ч \(m)м" }
        if h > 0 { return "\(h)ч" }
        if m > 0 { return "\(m)м" }
        return "\(seconds)с"
    }
    
    private func durationFromISO(departureISO: String, arrivalISO: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let depDate = formatter.date(from: departureISO),
              let arrDate = formatter.date(from: arrivalISO) else {
            return "2ч 30м"
        }
        
        let duration = Int(arrDate.timeIntervalSince(depDate))
        return humanizeDuration(seconds: duration)
    }
    
    private func formatDateToRu(_ ymd: String) -> String? {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        guard let date = inputFormatter.date(from: ymd) else { return nil }
        
        let outputFormatter = DateFormatter()
        outputFormatter.locale = Locale(identifier: "ru_RU")
        outputFormatter.dateFormat = "d MMMM"
        
        return outputFormatter.string(from: date)
    }
    
    private var todayYMD: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}
