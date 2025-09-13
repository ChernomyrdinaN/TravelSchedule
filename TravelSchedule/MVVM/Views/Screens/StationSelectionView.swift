//
//  StationSelectionView.swift
//  TravelSchedule
//
//  Created by Наталья Черномырдина on 11.09.2025.
//

import SwiftUI

struct StationSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedStation: Station?
    let city: String
    let onStationSelected: (Station) -> Void
    @State private var searchText = ""
    
    var body: some View {
        ZStack {
            Color.ypWhite
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Text("Выбор станции")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.ypBlack)
                    .padding(.top, 16)
                
                searchField
                
                if filteredStations.isEmpty {
                    noResultsView
                } else {
                    stationsList
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
        .toolbar(.hidden, for: .tabBar)
    }
    
    // MARK: - Private Properties
    private var cityStations: [Station] {
        Station.mockStations(for: city)
    }
    
    private var filteredStations: [Station] {
        if searchText.isEmpty {
            return cityStations
        } else {
            return cityStations.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    // MARK: - Private Views
    private var searchField: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.ypGray)
                .padding(.leading, 16)
            
            TextField("Введите запрос", text: $searchText)
                .padding(.vertical, 12)
                .foregroundColor(.ypBlack1)
                .tint(.ypBlack1)
            
            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.ypGray)
                        .padding(.trailing, 16)
                }
            }
        }
        .background(Color.ypLightGray)
        .cornerRadius(10)
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }
    
    private var stationsList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(filteredStations) { station in
                    stationRow(station: station)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            onStationSelected(station)
                        }
                }
            }
        }
    }
    
    private func stationRow(station: Station) -> some View {
        HStack {
            Text(station.name)
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(.ypBlack)
                .padding(.vertical, 12)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.ypBlack)
        }
        .padding(.horizontal, 16)
        .background(Color.ypWhite)
    }
    
    private var noResultsView: some View {
        VStack(spacing: 8) {
            Spacer()
            
            Text("Станция не найдена")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.ypBlack)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    StationSelectionView(
        selectedStation: .constant(nil),
        city: "Москва",
        onStationSelected: { _ in }
    )
}
