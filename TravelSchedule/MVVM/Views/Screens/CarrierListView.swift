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
    
    // MARK: - Initialization
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
    
    // MARK: - Body
    var body: some View {
        ZStack {
            Color.ypWhite.ignoresSafeArea()
            
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
        .onChange(of: filter) { _, _ in
            viewModel.applyFilters(filter)
        }
    }
    
    // MARK: - Private Views
    private var headerView: some View {
        Text("\(viewModel.fromStation.name) → \(viewModel.toStation.name)")
            .font(.system(size: 24, weight: .bold))
            .foregroundColor(.ypBlack)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
    }
    
    @ViewBuilder
    private var contentView: some View {
        if viewModel.isLoading {
            loadingView
        } else if let loadError = viewModel.loadError {
            errorView(message: loadError)
        } else if viewModel.filteredCarriers.isEmpty {
            emptyStateView
        } else {
            carriersList
        }
    }
    
    private var loadingView: some View {
        ZStack {
            Color.ypWhite.ignoresSafeArea()
            Image("loader")
                .resizable()
                .frame(width: 48, height: 48)
                .rotationEffect(Angle(degrees: rotationDegrees))
                .onAppear {
                    startLoadingAnimation()
                }
        }
    }
    
    private var carriersList: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(viewModel.filteredCarriers) { carrier in
                    NavigationLink {
                        CarrierInfoView(carrier: carrier)
                    } label: {
                        // ПРОСТО CarrierCardView БЕЗ ZStack
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
                Task { await viewModel.loadCarriers() }
            }
            .frame(height: 44)
            .frame(maxWidth: 180)
            .background(.ypBlueUniversal)
            .foregroundColor(.ypWhiteUniversal)
            .cornerRadius(10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: .zero) {
            Text("Вариантов нет")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.ypBlack)
                .multilineTextAlignment(.center)
                .padding(.top, 237)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Private Properties
    private var hasActiveFilters: Bool {
        !filter.timeOptions.isEmpty || filter.showTransfers != nil
    }
    
    // MARK: - Private Methods
    private func startLoadingAnimation() {
        withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
            rotationDegrees = 360
        }
    }
}

// MARK: - Extensions
private extension Carrier {
    var rasterLogoURL: URL? {
        guard let url = URL(string: self.logo), url.scheme?.hasPrefix("http") == true else { return nil }
        if url.path.lowercased().hasSuffix(".svg") { return nil }
        let rasterExts = ["png", "jpg", "jpeg", "webp", "gif", "bmp", "tif", "tiff"]
        let ext = url.pathExtension.lowercased()
        if rasterExts.contains(ext) { return url }
        if let q = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems,
           let fmt = q.first(where: { $0.name.lowercased() == "format" })?.value?.lowercased(),
           rasterExts.contains(fmt) {
            return url
        }
        return nil
    }
}
