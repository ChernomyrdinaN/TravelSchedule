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
    @Published var loadError: String?
    
    // MARK: - Public Properties
    let fromStation: Station
    let toStation: Station
    
    // MARK: - Private Properties
    private let apiClient: APIClient
    private let allowedTransportTypes: Set<String> = ["train", "suburban"]
    
    // MARK: - Init
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
            print("🔍 DEBUG Station codes:")
            print("   FROM: \(fromStation.name) [\(fromStation.code)]")
            print("   TO: \(toStation.name) [\(toStation.code)]")
            print("   DATE: \(todayYMD)")
            
            let response = try await apiClient.getScheduleBetweenStations(
                from: fromStation.code,
                to: toStation.code,
                date: todayYMD,
                transportTypes: Array(allowedTransportTypes),
                limit: 50,
                transfers: false
            )
            
            let allSegments = response.segments ?? []
            print("✅ API Response received, segments count: \(allSegments.count)")
            
            for (index, segment) in allSegments.prefix(3).enumerated() {
                print("   Segment \(index):")
                print("     from: \(segment.from?.title ?? "none")")
                print("     to: \(segment.to?.title ?? "none")")
                print("     departure: \(segment.departure ?? "none")")
                print("     thread: \(segment.thread?.title ?? "none")")
                print("     transport: \(segment.thread?.transport_type ?? "none")")
            }
            
            let transportFiltered = allSegments.filter { seg in
                guard let type = seg.thread?.transport_type?.lowercased() else { return true }
                return allowedTransportTypes.contains(type)
            }
            print("🚆 After transport filter: \(transportFiltered.count) segments")
            
            let dedupedSegments = dedupeSegments(transportFiltered)
            print("🔍 After deduplication: \(dedupedSegments.count) segments")
            
            self.carriers = mapSegmentsToCarriers(dedupedSegments)
            print("👥 Final carriers: \(self.carriers.count)")
            
            for (index, carrier) in self.carriers.prefix(3).enumerated() {
                print("   Carrier \(index): \(carrier.name) - \(carrier.departureTime)-\(carrier.arrivalTime)")
            }
            
            
            applyInitialFilters()
            
        } catch {
            print("❌ API Error: \(error)")
            self.loadError = "Ошибка загрузки: \(error.localizedDescription)"
            self.carriers = []
            self.filteredCarriers = []
        }
    }
    
    
    private func applyInitialFilters() {
        let initialFilter = CarrierFilter()
        applyFilters(initialFilter)
    }
    
    func applyFilters(_ filter: CarrierFilter) {
        print("🎛️ Applying filters: timeOptions=\(filter.timeOptions.count), showTransfers=\(filter.showTransfers ?? false)")
        
        var result = carriers
        
        if !filter.timeOptions.isEmpty {
            let beforeCount = result.count
            result = result.filter { carrier in
                guard let mins = minutes(from: carrier.departureTime) else { return true }
                return filter.timeOptions.contains { range in
                    let timeRange = timeRange(for: range)
                    return mins >= timeRange.start && mins <= timeRange.end
                }
            }
            print("⏰ Time filter: \(beforeCount) → \(result.count)")
        }
        
        if let showTransfers = filter.showTransfers {
            
            print("🔄 Transfers filter applied: \(showTransfers)")
        }
        
        filteredCarriers = result
        print("📊 Final filtered carriers: \(filteredCarriers.count)")
    }
    
    // MARK: - Private Methods
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
            
            let transferInfo: String? = nil
            
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
        
        print("🎯 Mapped \(segments.count) segments to \(result.count) carriers")
        return result
    }
    
    private func minutes(from hhmm: String) -> Int? {
        let parts = hhmm.split(separator: ":")
        guard parts.count == 2,
              let h = Int(parts[0]), let m = Int(parts[1]),
              (0...23).contains(h), (0...59).contains(m) else { return nil }
        return h * 60 + m
    }
    
    private func timeRange(for option: CarrierFilter.TimeOption) -> (start: Int, end: Int) {
        switch option {
        case .night: return (0, 5 * 60 + 59)
        case .morning: return (6 * 60, 11 * 60 + 59)
        case .afternoon: return (12 * 60, 17 * 60 + 59)
        case .evening: return (18 * 60, 23 * 60 + 59)
        }
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
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds, .withColonSeparatorInTimeZone]
        func parse(_ s: String) -> Date? {
            if let d = formatter.date(from: s) { return d }
            let fallback = ISO8601DateFormatter()
            fallback.formatOptions = [.withInternetDateTime, .withColonSeparatorInTimeZone]
            return fallback.date(from: s)
        }
        guard let dep = parse(departureISO), let arr = parse(arrivalISO) else { return "" }
        let seconds = Int(arr.timeIntervalSince(dep))
        return seconds > 0 ? humanizeDuration(seconds: seconds) : ""
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
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "Europe/Paris") ?? .current
        let comps = cal.dateComponents([.year, .month, .day], from: Date())
        let y = comps.year!, m = comps.month!, d = comps.day!
        let mm = String(format: "%02d", m), dd = String(format: "%02d", d)
        return "\(y)-\(mm)-\(dd)"
    }
}
