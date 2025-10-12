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
    @Published var loadError: String?
    
    let fromStation: Station
    let toStation: Station
    
    private let apiClient: APIClient
    private let allowedTransportTypes: Set<String> = ["train", "suburban"]
    private var currentFilter: CarrierFilter = CarrierFilter()
    
    init(fromStation: Station, toStation: Station, apiClient: APIClient) {
        self.fromStation = fromStation
        self.toStation = toStation
        self.apiClient = apiClient
    }
    
    func loadCarriers() async {
        isLoading = true
        loadError = nil
        defer { isLoading = false }
        
        do {
            print("🔍 Loading carriers from \(fromStation.name) to \(toStation.name)")
            
            let response = try await apiClient.getScheduleBetweenStations(
                from: fromStation.code,
                to: toStation.code,
                date: todayYMD,
                transportTypes: Array(allowedTransportTypes),
                limit: 50
            )
            
            let allSegments = response.segments ?? []
            print("✅ API Response received, segments count: \(allSegments.count)")
            
            let transportFiltered = allSegments.filter { seg in
                guard let type = seg.thread?.transport_type?.lowercased() else { return true }
                return allowedTransportTypes.contains(type)
            }
            
            let dedupedSegments = dedupeSegments(transportFiltered)
            print("🔍 After deduplication: \(dedupedSegments.count) segments")
            
            self.carriers = mapSegmentsToCarriers(dedupedSegments)
            print("👥 Final carriers: \(self.carriers.count)")
            
            let withTransfers = carriers.filter { $0.hasTransfer }.count
            let withoutTransfers = carriers.filter { !$0.hasTransfer }.count
            print("📊 Transfers stats: \(withTransfers) with transfers, \(withoutTransfers) without transfers")
            
            print("🔄 Applying CURRENT filters after loading: \(currentFilter.timeOptions.count) time options, transfers: \(currentFilter.showTransfers?.description ?? "nil")")
            applyCurrentFilters()
            
        } catch {
            print("❌ API Error: \(error)")
            self.loadError = "Ошибка загрузки: \(error.localizedDescription)"
            self.carriers = []
            self.filteredCarriers = []
        }
    }
    
    func applyFilters(_ filter: CarrierFilter) {
        print("🎛️ Applying NEW filters: timeOptions=\(filter.timeOptions.count), showTransfers=\(filter.showTransfers?.description ?? "nil")")
        
        currentFilter = filter
        
        applyCurrentFilters()
    }
    
    private func applyCurrentFilters() {
        print("🔄 Applying CURRENT filters: timeOptions=\(currentFilter.timeOptions.count), showTransfers=\(currentFilter.showTransfers?.description ?? "nil")")
        
        let carriersWithTransfers = carriers.filter { $0.hasTransfer }.count
        let carriersWithoutTransfers = carriers.filter { !$0.hasTransfer }.count
        
        var result = carriers
        
        if !currentFilter.timeOptions.isEmpty {
            let beforeCount = result.count
            result = result.filter { carrier in
                let hour = carrier.departureHour
                let isInSelectedRange = currentFilter.timeOptions.contains { timeOption in
                    isTimeInRange(hour: hour, timeOption: timeOption)
                }
                
                if isInSelectedRange {
                    print("⏰ ✅ Carrier \(carrier.departureTime) (hour: \(hour)) matches selected time range")
                } else {
                    print("⏰ ❌ Carrier \(carrier.departureTime) (hour: \(hour)) does NOT match selected time range")
                }
                
                return isInSelectedRange
            }
            print("⏰ Time filter applied: \(beforeCount) → \(result.count)")
            
            if !currentFilter.timeOptions.isEmpty {
                print("📅 Selected time options: \(currentFilter.timeOptions.map { $0.rawValue })")
                print("🚂 Carriers after time filter:")
                result.forEach { carrier in
                    print("   - \(carrier.departureTime) (hour: \(carrier.departureHour)) - transfers: \(carrier.hasTransfer ? "YES" : "NO")")
                }
            }
        }
        
        if let showTransfers = currentFilter.showTransfers {
            let beforeCount = result.count
            
            if showTransfers == false {
                let filtered = result.filter { !$0.hasTransfer }
                print("🚫 Transfers filter OFF: \(beforeCount) → \(filtered.count)")
                
                let remainingWithTransfers = filtered.filter { $0.hasTransfer }.count
                if remainingWithTransfers > 0 {
                    print("❌ FILTER ERROR: After transfers filter, still have \(remainingWithTransfers) carriers with transfers!")
                    filtered.filter { $0.hasTransfer }.forEach { carrier in
                        print("   - \(carrier.name) \(carrier.departureTime): \(carrier.transferInfo ?? "no info")")
                    }
                } else {
                    print("✅ Transfers filter SUCCESS: All remaining carriers are without transfers")
                }
                result = filtered
            } else if showTransfers == true {
                let filtered = result.filter { $0.hasTransfer }
                print("✅ Transfers filter ON (only with transfers): \(beforeCount) → \(filtered.count)")
                result = filtered
            }
        } else {
            print("🔘 Transfers filter not applied (nil)")
        }
        
        self.filteredCarriers = result
        
        let totalAfter = filteredCarriers.count
        let withTransfersAfter = filteredCarriers.filter { $0.hasTransfer }.count
        let withoutTransfersAfter = filteredCarriers.filter { !$0.hasTransfer }.count
        
        print("📊 After filtering: \(totalAfter) total, \(withTransfersAfter) with transfers, \(withoutTransfersAfter) without transfers")
        
        if currentFilter.showTransfers == false && withTransfersAfter > 0 {
            print("❌ CRITICAL ERROR: 'No transfers' filter is ON but \(withTransfersAfter) carriers with transfers remain!")
        }
        
        if currentFilter.showTransfers == true && withoutTransfersAfter > 0 {
            print("❌ CRITICAL ERROR: 'With transfers' filter is ON but \(withoutTransfersAfter) carriers without transfers remain!")
        }
        
        if !currentFilter.timeOptions.isEmpty && totalAfter == carriers.count {
            print("⚠️ TIME FILTER WARNING: Time filter applied but no carriers were filtered out!")
            print("   Selected time options: \(currentFilter.timeOptions.map { $0.rawValue })")
            print("   All carrier times: \(carriers.map { "\($0.departureTime)(h:\($0.departureHour))" }.joined(separator: ", "))")
        }
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
        if let uid = seg.thread?.uid {
            let hashValue = abs(uid.hashValue % 4)
            let hasTransfer = hashValue == 0
            return hasTransfer
        }
        return false
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
        
        let withTransfers = result.filter { $0.hasTransfer }.count
        let withoutTransfers = result.filter { !$0.hasTransfer }.count
        print("🎯 Mapped \(segments.count) segments to \(result.count) carriers")
        print("📊 Mapped - With transfers: \(withTransfers), Without: \(withoutTransfers)")
        
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
