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
            } else {
                VStack(spacing: .zero) {
                    headerView
                        .padding(.top, 16)
                        .background(Color.ypWhite)
                    
                    contentView
                }
                
                VStack {
                    Spacer()
                    clarifyTimeButton
                        .padding(.horizontal, 16)
                        .padding(.bottom, 24)
                }
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
            await viewModel.loadCarriers()
        }
        .onChange(of: filter) { oldFilter, newFilter in
            viewModel.applyFilters(newFilter)
        }
    }
    
    private var headerView: some View {
        Text("\(viewModel.fromStation.name) → \(viewModel.toStation.name)")
            .font(.system(size: 24, weight: .bold))
            .foregroundColor(.ypBlack)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
    }
    
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
    
    private var loadingView: some View {
        VStack {
            Spacer()
            
            Image("loader")
                .resizable()
                .frame(width: 48, height: 48)
                .rotationEffect(Angle(degrees: rotationDegrees))
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            startLoadingAnimation()
        }
        .onDisappear {
            stopLoadingAnimation()
        }
    }
    
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
    
    private func errorView(message: String) -> some View {
        ErrorView(errorModel: .error2)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: .zero) {
            Text("Вариантов нет")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.ypBlack)
                .multilineTextAlignment(.center)
                .kerning(0)
                .padding(.top, 237)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var hasActiveFilters: Bool {
        !filter.timeOptions.isEmpty || filter.showTransfers != nil
    }
    
    private func startLoadingAnimation() {
        guard !isLoaderAnimating else { return }
        isLoaderAnimating = true
        rotationDegrees = 0
        
        withAnimation(nil) {
            rotationDegrees = 0
        }
        
        withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
            rotationDegrees = 360
        }
    }
    
    private func stopLoadingAnimation() {
        isLoaderAnimating = false
        rotationDegrees = 0
    }
}
