//
//  CarrierListView.swift
//  TravelSchedule
//
//  Created by Наталья Черномырдина on 12.09.2025.
//

import SwiftUI

struct CarrierListView: View {
    let fromStation: Station
    let toStation: Station
    
    @Binding var navigationPath: NavigationPath
    @Binding var filter: CarrierFilter
    
    @State private var carriers: [Carrier] = []
    @State private var filteredCarriers: [Carrier] = []
    
    @State private var apiSegmentsCount = 0
    @State private var filteredSegmentsCount = 0
    @State private var dedupedSegmentsCount = 0
    
    @State private var isLoading = false
    @State private var loadError: String?
    
    private let apiClient = DIContainer.shared.apiClient
    
    private let allowedTransportTypes: Set<String> = ["train", "suburban"]
    
    // MARK: - Init
    init(fromStation: Station,
         toStation: Station,
         navigationPath: Binding<NavigationPath>,
         filter: Binding<CarrierFilter>) {
        self.fromStation = fromStation
        self.toStation = toStation
        self._navigationPath = navigationPath
        self._filter = filter
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            Color.ypWhite.ignoresSafeArea()
            
            VStack(spacing: .zero) {
                headerView
                    .padding(.top, 16)
                    .background(Color.ypWhite)
                
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let loadError {
                    errorView(message: loadError)
                } else if filteredCarriers.isEmpty {
                    emptyStateView
                } else {
                    carriersList
                }
            }
            
            VStack {
                Spacer()
                clarifyTimeButton
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { navigationPath.removeLast() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.ypBlack)
                }
            }
        }
        .toolbar(.hidden, for: .tabBar)
        .task {
            await loadCarriers()
        }
        .onChange(of: filter) { _, _ in
            applyFilters()
        }
    }
    
    // MARK: - Private Views
    
    private var headerView: some View {
        Text("\(fromStation.name) → \(toStation.name) — \(formattedTodayRu)")
            .font(.system(size: 24, weight: .bold))
            .foregroundColor(.ypBlack)
            .lineLimit(2)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
    }
    
    private var diagnosticsHeader: some View {
        HStack(spacing: 8) {
            pill("API: \(apiSegmentsCount)")
            pill("После фильтра: \(filteredSegmentsCount)")
            pill("После дедупа: \(dedupedSegmentsCount)")
            Spacer()
        }
    }
    
    private func pill(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(.ypBlack)
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .background(Color.ypLightGray)
            .cornerRadius(8)
    }
    
    private var carriersList: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(Array(filteredCarriers.enumerated()), id: \.element.id) { _, carrier in
                    NavigationLink {
                        CarrierInfoView(carrier: carrier)
                    } label: {
                        ZStack(alignment: .topLeading) {
                            CarrierCardView(
                                carrier: carrier,
                                onTimeClarificationTapped: {
                                    navigationPath.append(NavigationModels.filters)
                                }
                            )
                            
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.ypWhite)
                                .frame(width: 40, height: 40)
                                .padding(.top, 12)
                                .padding(.leading, 16)
                            
                            if let url = carrier.rasterLogoURL {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                            .frame(width: 40, height: 40)
                                            .padding(.top, 12)
                                            .padding(.leading, 16)
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 40, height: 40)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                            .padding(.top, 12)
                                            .padding(.leading, 16)
                                    case .failure:
                                        EmptyView()
                                            .frame(width: 40, height: 40)
                                            .padding(.top, 12)
                                            .padding(.leading, 16)
                                    @unknown default:
                                        EmptyView()
                                            .frame(width: 40, height: 40)
                                            .padding(.top, 12)
                                            .padding(.leading, 16)
                                    }
                                }
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .background(Color.ypLightGray)
                    .cornerRadius(24)
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    private var clarifyTimeButton: some View {
        Button(action: { navigationPath.append(NavigationModels.filters) }) {
            HStack {
                Text("Уточнить время")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.ypWhiteUniversal)
                if hasActiveFilters {
                    Circle().fill(Color.red).frame(width: 8, height: 8)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(.ypBlueUniversal)
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
        .background(Color.ypLightGray)
        .cornerRadius(12)
    }
    
    private func errorView(message: String) -> some View {
        VStack(spacing: 12) {
            Text("Не удалось загрузить")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.ypBlack)
            Text(message)
                .font(.system(size: 15))
                .foregroundColor(.ypBlack)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
            Button("Повторить") { Task { await loadCarriers() } }
                .frame(height: 44)
                .frame(maxWidth: 180)
                .background(.ypBlueUniversal)
                .foregroundColor(.ypWhiteUniversal)
                .cornerRadius(10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: .zero) {
            Text("Вариантов нет")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.ypBlack)
                .multilineTextAlignment(.center)
                .padding(.top, 237)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Private Properties
    private var hasActiveFilters: Bool {
        !filter.timeOptions.isEmpty || filter.showTransfers != nil
    }
    
    // MARK: - Networking / Mapping
    
    private func loadCarriers() async {
        isLoading = true
        loadError = nil
        defer { isLoading = false }
        
        do {
#if DEBUG
            print("🔎 Search request: from=\(fromStation.code) to=\(toStation.code) date=\(todayYMD)")
#endif
            
            let response = try await apiClient.getScheduleBetweenStations(
                from: fromStation.code,
                to: toStation.code,
                date: todayYMD,
                transportTypes: Array(allowedTransportTypes),
                limit: 50,
                transfers: false
            )
            let allSegments: [Components.Schemas.Segment] = response
            apiSegmentsCount = allSegments.count
            
            let transportFiltered = allSegments.filter { seg in
                guard let type = seg.thread?.transport_type?.lowercased() else { return true }
                return allowedTransportTypes.contains(type)
            }
            filteredSegmentsCount = transportFiltered.count
            let dedupedSegments = dedupeSegments(transportFiltered)
            dedupedSegmentsCount = dedupedSegments.count
            
            let mapped = mapSegmentsToCarriers(dedupedSegments)
            self.carriers = mapped
            
#if DEBUG
            print("📦 API segments:", apiSegmentsCount,
                  "| type filtered:", filteredSegmentsCount,
                  "| deduped:", dedupedSegmentsCount)
            mapped.prefix(12).enumerated().forEach { idx, c in
                print("— [\(idx)] \(c.debugLine)")
            }
#endif
            
            applyFilters()
        } catch {
#if DEBUG
            print("❌ Search error:", error.localizedDescription)
#endif
            self.loadError = (error as NSError).localizedDescription
            self.carriers = []
            self.filteredCarriers = []
            apiSegmentsCount = 0
            filteredSegmentsCount = 0
            dedupedSegmentsCount = 0
        }
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
        segments.compactMap { seg in
            let departureISO = seg.departure ?? ""
            let arrivalISO   = seg.arrival ?? ""
            let (depDate, depTime) = splitISO(departureISO)
            let (_, arrTime)       = splitISO(arrivalISO)
            
            
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
                date: depDate,
                departureTime: depTime,
                travelTime: travelTime,
                arrivalTime: arrTime
            )
        }
    }
    
    // MARK: - Helpers
    
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
    
    private var todayYMD: String {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "Europe/Paris") ?? .current
        let comps = cal.dateComponents([.year, .month, .day], from: Date())
        let y = comps.year!, m = comps.month!, d = comps.day!
        let mm = String(format: "%02d", m), dd = String(format: "%02d", d)
        return "\(y)-\(mm)-\(dd)"
    }
    
    private var formattedTodayRu: String {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "Europe/Paris") ?? .current
        let date = Date()
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.calendar = cal
        formatter.timeZone = cal.timeZone
        formatter.dateFormat = "d MMMM"
        return formatter.string(from: date)
    }
    
    // MARK: - Filtering
    private func applyFilters() {
        var result = carriers
        
        if !filter.timeOptions.isEmpty {
            func minutes(_ hhmm: String) -> Int? {
                let parts = hhmm.split(separator: ":")
                guard parts.count == 2,
                      let h = Int(parts[0]), let m = Int(parts[1]),
                      (0...23).contains(h), (0...59).contains(m) else { return nil }
                return h * 60 + m
            }
            
            struct Range { let start: Int; let end: Int }
            var ranges: [Range] = []
            for opt in filter.timeOptions {
                switch opt {
                case .night:
                    ranges.append(.init(start: 0, end: 5 * 60 + 59))
                case .morning:
                    ranges.append(.init(start: 6 * 60, end: 11 * 60 + 59))
                case .afternoon:
                    ranges.append(.init(start: 12 * 60, end: 17 * 60 + 59))
                case .evening:
                    ranges.append(.init(start: 18 * 60, end: 23 * 60 + 59))
                }
            }
            
            result = result.filter { carrier in
                guard let mins = minutes(carrier.departureTime) else { return true }
                return ranges.contains { r in mins >= r.start && mins <= r.end }
            }
        }
        
        
        if let _ = filter.showTransfers {
        }
        
        filteredCarriers = result
    }
}

// MARK: - Debug / Logo helpers

private extension Carrier {
    var rasterLogoURL: URL? {
        guard let url = URL(string: self.logo), url.scheme?.hasPrefix("http") == true else { return nil }
        if url.path.lowercased().hasSuffix(".svg") { return nil }
        let rasterExts = ["png", "jpg", "jpeg", "webp", "gif", "bmp", "tif", "tiff"]
        let ext = url.pathExtension.lowercased()
        if rasterExts.contains(ext) { return url }
        if let q = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems,
           let fmt = q.first(where: { $0.name.lowercased() == "format" })?.value?.lowercased(),
           rasterExts.contains(fmt) {
            return url
        }
        return nil
    }
    
    var debugLine: String {
        "[\(date) \(departureTime)→\(arrivalTime)] \(name) | logo=\(logo)"
    }
}

