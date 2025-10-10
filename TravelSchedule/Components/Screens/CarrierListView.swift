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
    @State private var showLoader = false
    
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
            
            // MARK: - Main Content
            VStack(spacing: .zero) {
                headerView
                    .padding(.top, 16)
                    .background(Color.ypWhite)
                
                contentView
            }
            
            // MARK: - Bottom Button
            VStack {
                Spacer()
                clarifyTimeButton
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
            }
            
            // MARK: - Loader Overlay
            if viewModel.isLoading || showLoader {
                Color.ypWhite.opacity(0.9)
                    .ignoresSafeArea()
                
                loadingView
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
            showLoader = true
            await viewModel.loadCarriers()
            showLoader = false
        }
        .onChange(of: filter) { _, _ in
            viewModel.applyFilters(filter)
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        Text("\(viewModel.fromStation.name) → \(viewModel.toStation.name)")
            .font(.system(size: 24, weight: .bold))
            .foregroundColor(.ypBlack)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
    }
    
    // MARK: - Content
    @ViewBuilder
    private var contentView: some View {
        if let loadError = viewModel.loadError {
            errorView(message: loadError)
        } else if viewModel.filteredCarriers.isEmpty {
            emptyStateView
        } else {
            carriersList
        }
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 16) {
            Image("loader")
                .resizable()
                .frame(width: 48, height: 48)
                .rotationEffect(Angle(degrees: rotationDegrees))
            
            Text("Загружаем расписание...")
                .font(.system(size: 17))
                .foregroundColor(.ypBlack)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            startLoadingAnimation()
        }
        .onDisappear {
            stopLoadingAnimation()
        }
    }
    
    // MARK: - Carriers List
    private var carriersList: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(viewModel.filteredCarriers) { carrier in
                    NavigationLink {
                        CarrierInfoView(carrier: carrier)
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
        }
    }
    
    // MARK: - Clarify Time Button
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
    
    // MARK: - Error View
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
            Button("Повторить") {
                Task {
                    showLoader = true
                    await viewModel.loadCarriers()
                    showLoader = false
                }
            }
            .frame(height: 44)
            .frame(maxWidth: 180)
            .background(.ypBlueUniversal)
            .foregroundColor(.ypWhiteUniversal)
            .cornerRadius(10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: .zero) {
            Text("Вариантов нет")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.ypBlack)
                .multilineTextAlignment(.center)
                .padding(.top, 100)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Helper Properties
    private var hasActiveFilters: Bool {
        !filter.timeOptions.isEmpty || filter.showTransfers != nil
    }
    
    // MARK: - Animation Methods
    private func startLoadingAnimation() {
        guard !isLoaderAnimating else { return }
        isLoaderAnimating = true
        rotationDegrees = 0
        
        withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
            rotationDegrees = 360
        }
    }
    
    private func stopLoadingAnimation() {
        isLoaderAnimating = false
        rotationDegrees = 0
    }
}
