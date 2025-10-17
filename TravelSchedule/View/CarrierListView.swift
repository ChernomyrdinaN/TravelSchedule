//
//  CarrierListView.swift
//  TravelSchedule
//
//  Created by Наталья Черномырдина on 12.09.2025.
//

import SwiftUI

struct CarrierListView: View {
    @StateObject private var viewModel: CarrierListViewModel
    @Binding var navigationPath: NavigationPath
    @Binding var filter: CarrierFilter
    
    @State private var rotationDegrees: Double = 0
    @State private var isLoaderAnimating = false
    
    // MARK: - Init
    init(fromStation: Station,
         toStation: Station,
         navigationPath: Binding<NavigationPath>,
         filter: Binding<CarrierFilter>) {
        let apiClient = DIContainer.shared.apiClient
        _viewModel = StateObject(wrappedValue: CarrierListViewModel(
            fromStation: fromStation,
            toStation: toStation,
            apiClient: apiClient
        ))
        self._navigationPath = navigationPath
        self._filter = filter
    }
    
    var body: some View {
        ZStack {
            Color.ypWhite.ignoresSafeArea()
            
            if viewModel.isLoading {
                loadingView
            } else if let loadError = viewModel.loadError {
                ErrorView(errorModel: loadError)
                    .onTapGesture {
                        navigationPath.removeLast(navigationPath.count)
                    }
            } else if viewModel.hasEmptyResults || viewModel.filteredCarriers.isEmpty {
                emptyStateView
            } else {
                mainContent
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(viewModel.loadError != nil ? .visible : .hidden, for: .tabBar)
        .task {
            await viewModel.loadCarriers()
        }
        .onChange(of: filter) { oldFilter, newFilter in
            viewModel.applyFilters(newFilter)
        }
    }
}

// MARK: - Private Views
private extension CarrierListView {
    var mainContent: some View {
        VStack(spacing: .zero) {
            HStack {
                backButton
                    .padding(.leading, 8)
                
                Spacer()
            }
            .padding(.bottom, 8)
            
            headerView
                .padding(.top, 16)
                .background(Color.ypWhite)
            
            contentView
        }
    }
    
    var headerView: some View {
        Text("\(viewModel.fromStation.name) → \(viewModel.toStation.name)")
            .font(.system(size: 24, weight: .bold))
            .foregroundColor(.ypBlack)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
    }
    
    @ViewBuilder
    var contentView: some View {
        ZStack(alignment: .bottom) {
            carriersList
            clarifyTimeButton
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
        }
    }
    
    var loadingView: some View {
        VStack {
            Spacer()
            Image("loader")
                .resizable()
                .frame(width: 48, height: 48)
                .rotationEffect(Angle(degrees: rotationDegrees))
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear { startLoadingAnimation() }
        .onDisappear { stopLoadingAnimation() }
    }
    
    var carriersList: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(viewModel.filteredCarriers) { carrier in
                    NavigationLink {
                        CarrierInfoView(carrier: carrier, apiClient: viewModel.apiClient)
                    } label: {
                        CarrierCardView(
                            carrier: carrier,
                            onTimeClarificationTapped: {
                                navigationPath.append(NavigationModels.filters)
                            }
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .background(Color.ypLightGray)
                    .cornerRadius(24)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 80)
        }
    }
    
    var clarifyTimeButton: some View {
        Button(action: { navigationPath.append(NavigationModels.filters) }) {
            HStack {
                Text("Уточнить время")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.ypWhiteUniversal)
                
                if hasActiveFilters {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
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
    
    var emptyStateView: some View {
        VStack(spacing: .zero) {
            HStack {
                backButton
                    .padding(.leading, 16)
                    .padding(.top, 16)
                
                Spacer()
            }
            
            Text("Вариантов нет")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.ypBlack)
                .multilineTextAlignment(.center)
                .kerning(0)
                .padding(.top, 260)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    var backButton: some View {
        Button(action: {
            navigationPath.removeLast(navigationPath.count)
        }) {
            HStack(spacing: 4) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .medium))
            }
            .foregroundColor(.ypBlack)
        }
    }
}

// MARK: - Private Properties & Methods
private extension CarrierListView {
    var hasActiveFilters: Bool {
        !filter.timeOptions.isEmpty || filter.showTransfers != nil
    }
    
    func startLoadingAnimation() {
        guard !isLoaderAnimating else { return }
        isLoaderAnimating = true
        rotationDegrees = 0
        
        withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
            rotationDegrees = 360
        }
    }
    
    func stopLoadingAnimation() {
        isLoaderAnimating = false
        rotationDegrees = 0
    }
}
