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
    @State private var carriers = Carrier.mockData
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Body
    
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
     
                    clarifyTimeButton
                        .padding(.top, 16)
                        .padding(.horizontal, 16)
                }
                
                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.ypBlack)
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(fromStation) → \(toStation)")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.ypBlack)
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
            Text("Уточнить время")
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(.ypWhite)
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
            
            Text("Попробуйте изменить параметры фильтра")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.ypGray)
            
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
