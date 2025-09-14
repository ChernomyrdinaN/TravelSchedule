//
//  CarrierListView.swift
//  TravelSchedule
//
//  Created by Наталья Черномырдина on 12.09.2025.
//
import SwiftUI

struct CarrierListView: View {
    let fromStation: String
    let toStation: String
    @Binding var navigationPath: NavigationPath
    @Binding var filter: CarrierFilter
    @State private var carriers: [Carrier]
    @State private var filteredCarriers: [Carrier] = []
    
    init(fromStation: String, toStation: String, navigationPath: Binding<NavigationPath>, filter: Binding<CarrierFilter>, carriers: [Carrier] = Carrier.mockData) {
        self.fromStation = fromStation
        self.toStation = toStation
        self._navigationPath = navigationPath
        self._filter = filter
        self._carriers = State(initialValue: carriers)
        self._filteredCarriers = State(initialValue: carriers)
    }
    
    var body: some View {
        ZStack {
            Color.ypWhite
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerView
                
                if filteredCarriers.isEmpty {
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
                Button(action: {
                    navigationPath.removeLast()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.ypBlack)
                }
            }
        }
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            applyFilters()
        }
    }
    
    // MARK: - Private Views
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(fromStation) → \(toStation)")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.ypBlack)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 16)
                .padding(.horizontal, 16)
        }
    }
    
    private var carriersList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(filteredCarriers) { carrier in
                    CarrierCardView(
                        carrier: carrier,
                        onTimeClarificationTapped: {
                            navigationPath.append(StationNavigation.filters)
                        }
                    )
                    .background(Color.ypLightGray)
                    .cornerRadius(24)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
        }
    }
    
    private var clarifyTimeButton: some View {
        Button(action: {
            navigationPath.append(StationNavigation.filters)
        }) {
            HStack {
                Text("Уточнить время")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(.ypWhite1)
                
                if hasActiveFilters {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(Color.ypBlue)
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
        .background(Color.ypLightGray)
        .cornerRadius(12)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 0) {
            Text("Вариантов нет")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.ypBlack)
                .multilineTextAlignment(.center)
                .lineSpacing(0)
                .kerning(0)
                .padding(.top, 237)
             
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Private Properties
    private var hasActiveFilters: Bool {
        !filter.timeOptions.isEmpty || filter.showTransfers != nil
    }
    
    // MARK: - Private Methods
    private func applyFilters() {
        if filter.timeOptions.isEmpty && filter.showTransfers == nil {
            filteredCarriers = carriers
            return
        }
        
        filteredCarriers = carriers.filter { carrier in
            if let showTransfers = filter.showTransfers {
                let hasTransfer = carrier.transferInfo != nil
                if showTransfers && !hasTransfer {
                    return false
                }
                if !showTransfers && hasTransfer {
                    return false
                }
            }
            
            if !filter.timeOptions.isEmpty {
                let hour = carrier.departureHour
                var matchesTime = false
                
                for timeOption in filter.timeOptions {
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
}

#Preview {
    CarrierListView(
        fromStation: "Москва (Ярославский вокзал)",
        toStation: "Санкт-Петербург (Балтийский вокзал)",
        navigationPath: .constant(NavigationPath()),
        filter: .constant(CarrierFilter())
    )
}

#Preview("Без перевозчиков") {
    CarrierListView(
        fromStation: "Москва (Ярославский вокзал)",
        toStation: "Санкт-Петербург (Балтийский вокзал)",
        navigationPath: .constant(NavigationPath()),
        filter: .constant(CarrierFilter()),
        carriers: []
    )
}
