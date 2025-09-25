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
    
    // MARK: - Body
    var body: some View {
        ZStack {
            Color.ypWhite
                .ignoresSafeArea()
            
            VStack(spacing: .zero) {
                searchField
                if filteredStations.isEmpty {
                    noResultsView
                } else {
                    stationsList
                        .padding(.top, 8)
                }
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
                    .foregroundColor(.ypGrayUniversal)
                    .padding(.leading, 8)
                
                TextField("Введите запрос", text: $searchText)
                    .padding(.vertical, 6)
                    .foregroundColor(.ypBlack)
                    .tint(.ypBlack)
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.ypGrayUniversal)
                            .padding(.horizontal, 8)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 36)
            .background(.ypSearchField)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .padding(.horizontal, 16)
        }
        
        private var stationsList: some View {
            ScrollView {
                LazyVStack(spacing: .zero) {
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
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.ypBlack)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .frame(height: 60)
        }
        
        // MARK: - No Results View
    private var noResultsView: some View {
        VStack(spacing: .zero) {
              Text("Станция не найдена")
                  .font(.system(size: 24, weight: .bold))
                  .foregroundColor(.ypBlack)
                  .multilineTextAlignment(.center)
                  .padding(.top, 228)
              
              Spacer()
          }
          .frame(maxWidth: .infinity)
      }
  }

// MARK: - Preview
    #Preview {
        NavigationView {
            StationSelectionView(
                selectedStation: .constant(nil),
                city: "Москва",
                onStationSelected: { _ in }
            )
        }
    }
