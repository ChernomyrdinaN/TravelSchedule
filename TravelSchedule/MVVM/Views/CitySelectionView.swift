//
//  CitySelectionView.swift
//  TravelSchedule
//
//  Created by Наталья Черномырдина on 10.09.2025.
//

import SwiftUI

struct CitySelectionView: View {
    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedStation: Station?
    let onStationSelected: (Station) -> Void
    
    @State private var searchText = ""
    @State private var isSearching = false
    
    private var filteredStations: [Station] {
        if searchText.isEmpty {
            return Station.mockData
        } else {
            return Station.mockData.filter { station in
                station.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                Color.ypWhite
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Text("Выбор города")
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
        }
    }
    
    // MARK: - Subviews
    private var searchField: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.ypGray)
                .padding(.leading, 16)
            
            TextField("Введите запрос", text: $searchText)
                .padding(.vertical, 12)
                .foregroundColor(.ypBlack)
                .onChange(of: searchText) { oldValue, newValue in
                    isSearching = !newValue.isEmpty
                }
            
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
                            dismiss()
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
            
            if selectedStation?.id == station.id {
                Image(systemName: "checkmark")
                    .foregroundColor(.ypBlue)
            }
        }
        .padding(.horizontal, 16)
        .background(Color.ypWhite)
    }
    
    private var noResultsView: some View {
        VStack(spacing: 8) {
            Spacer()
            
            Text("Город не найден")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.ypBlack)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}
