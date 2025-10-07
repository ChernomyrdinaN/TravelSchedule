//
//  StationSelectionView.swift
//  TravelSchedule
//
//  Created by Наталья Черномырдина on 11.09.2025.
//

import SwiftUI

// MARK: - StationSelectionView
struct StationSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedStation: Station?
    let city: String
    let onStationSelected: (Station) -> Void
    
    @StateObject private var viewModel: StationSelectionViewModel
    @State private var searchText = ""
    @State private var rotationDegrees = 0.0
    @State private var isFirstLoad = true
    
    init(selectedStation: Binding<Station?>, city: String, onStationSelected: @escaping (Station) -> Void) {
        self._selectedStation = selectedStation
        self.city = city
        self.onStationSelected = onStationSelected
        self._viewModel = StateObject(wrappedValue: StationSelectionViewModel(city: city))
    }
    
    var body: some View {
        ZStack {
            Color.ypWhite
                .ignoresSafeArea()
            
            VStack(spacing: .zero) {
                searchField
                    .disabled(viewModel.isLoading && isFirstLoad)
                
                if viewModel.isLoading && isFirstLoad {
                    loadingView
                }
                else if viewModel.filteredStations.isEmpty {
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
        .task {
            if viewModel.stations.isEmpty {
                await viewModel.loadStations()
                isFirstLoad = false
            }
        }
        .onChange(of: searchText) { oldValue, newValue in
            viewModel.filterStations(searchText: newValue)
        }
        .onChange(of: viewModel.isLoading) { oldValue, newValue in
            if newValue && isFirstLoad {
                startLoaderAnimation()
            }
        }
    }
}

// MARK: - View Components
private extension StationSelectionView {
    var searchField: some View {
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
    
    var stationsList: some View {
        ScrollView {
            LazyVStack(spacing: .zero) {
                ForEach(viewModel.filteredStations) { station in
                    stationRow(station: station)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            onStationSelected(station)
                        }
                }
            }
        }
    }
    
    func stationRow(station: Station) -> some View {
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
    
    var loadingView: some View {
        VStack(spacing: .zero) {
            Image("loader")
                .resizable()
                .frame(width: 60, height: 60)
                .rotationEffect(Angle(degrees: rotationDegrees))
                .padding(.top, 228)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
    
    var noResultsView: some View {
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
    
    func startLoaderAnimation() {
        rotationDegrees = 0
        withAnimation(.linear(duration: 1.1).repeatForever(autoreverses: false)) {
            rotationDegrees = 360
        }
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
