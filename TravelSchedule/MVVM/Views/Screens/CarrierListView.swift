//
//  CarrierListView.swift
//  TravelSchedule
//
//  Created by Наталья Черномырдина on 12.09.2025.
//
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
    @State private var carriers: [Carrier]
    
    init(fromStation: String, toStation: String, navigationPath: Binding<NavigationPath>, carriers: [Carrier] = Carrier.mockData) {
        self.fromStation = fromStation
        self.toStation = toStation
        self._navigationPath = navigationPath
        self._carriers = State(initialValue: carriers)
    }
    
    var body: some View {
        ZStack {
            Color.ypWhite
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerView
                
                if carriers.isEmpty {
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
                ForEach(carriers) { carrier in
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
                
                Circle()
                    .fill(Color.red)
                    .frame(width: 8, height: 8)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(Color.ypBlue)
            .cornerRadius(12)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 8) {
            Spacer()
            
            Text("Варианты не найдены")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.ypBlack)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    CarrierListView(
        fromStation: "Москва (Ярославский вокзал)",
        toStation: "Санкт-Петербург (Балтийский вокзал)",
        navigationPath: .constant(NavigationPath())
    )
}

#Preview("Без перевозчиков") {
    CarrierListView(
        fromStation: "Москва (Ярославский вокзал)",
        toStation: "Санкт-Петербург (Балтийский вокзал)",
        navigationPath: .constant(NavigationPath()),
        carriers: []
    )
}
