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
                searchField
                    .padding(.top, 8)
                
                if filteredStations.isEmpty {
                    noResultsView
                } else {
                    stationsList
                        .padding(.top, 8)
                }
                
                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle("Выбор станции")
        .navigationBarTitleDisplayMode(.inline)
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
        .frame(height: 42)
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
                .padding(.vertical, 19)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.ypBlack)
        }
        .padding(.horizontal, 16)
        .frame(height: 60)
        .background(Color.ypWhite)
    }
    
    // MARK: - No Results View
    private var noResultsView: some View {
        VStack(spacing: 0) {
            Text("Станция не найдена")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.ypBlack)
                .multilineTextAlignment(.center)
                .lineSpacing(0)
                .kerning(0)
                .padding(.top, 228)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    NavigationView {
        StationSelectionView(
            selectedStation: .constant(nil),
            city: "Москва",
            onStationSelected: { _ in }
        )
    }
}
