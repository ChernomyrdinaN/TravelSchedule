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
            
            VStack(spacing: .zero) {
                if !shouldHideHeader {
                    headerView
                        .padding(.top, 16)
                        .background(Color.ypWhite)
                }
                
                contentView
            }
            
            if !shouldHideHeader {
                VStack {
                    Spacer()
                    clarifyTimeButton
                        .padding(.horizontal, 16)
                        .padding(.bottom, 24)
                }
            }
            
            if viewModel.isLoading || showLoader {
                Color.ypWhite.opacity(0.9)
                    .ignoresSafeArea()
                
                loadingView
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            if shouldShowBackButton {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { navigationPath.removeLast() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.ypBlack)
                    }
                }
            }
        }
        .toolbar(.hidden, for: shouldHideTabBar ? .tabBar : .automatic)
        .task {
            showLoader = true
            await viewModel.loadCarriers()
            showLoader = false
        }
        .onChange(of: filter) { oldFilter, newFilter in
            print("🔄 CarrierListView: Filter changed!")
            print("   Old: time=\(oldFilter.timeOptions.count), transfers=\(oldFilter.showTransfers?.description ?? "nil")")
            print("   New: time=\(newFilter.timeOptions.count), transfers=\(newFilter.showTransfers?.description ?? "nil")")
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
            .padding(.bottom, 8)
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
        VStack(spacing: 8) {
            if hasActiveFilters {
                HStack {
                    Text("Активные фильтры:")
                        .font(.system(size: 14))
                        .foregroundColor(.ypBlack)
                    
                    if !filter.timeOptions.isEmpty {
                        Text("Время (\(filter.timeOptions.count))")
                            .font(.system(size: 12))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.ypBlueUniversal.opacity(0.2))
                            .cornerRadius(8)
                    }
                    
                    if filter.showTransfers != nil {
                        Text(filter.showTransfers == false ? "Без пересадок" : "С пересадками")
                            .font(.system(size: 12))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.ypBlueUniversal.opacity(0.2))
                            .cornerRadius(8)
                    }
                    
                    Spacer()
                    
                    Button("Сбросить") {
                        print("🔄 Resetting filters in view")
                        filter = CarrierFilter()
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.ypBlueUniversal)
                }
                .padding(.horizontal, 16)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Отладочная информация:")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray)
                Text("Всего carriers: \(viewModel.carriers.count)")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                Text("Отфильтровано: \(viewModel.filteredCarriers.count)")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                Text("С пересадками: \(viewModel.filteredCarriers.filter { $0.hasTransfer }.count)")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                Text("Без пересадок: \(viewModel.filteredCarriers.filter { !$0.hasTransfer }.count)")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                
                if filter.showTransfers == false {
                    let incorrectCount = viewModel.filteredCarriers.filter { $0.hasTransfer }.count
                    if incorrectCount > 0 {
                        Text("❌ ОШИБКА: Найдено \(incorrectCount) маршрутов с пересадками при фильтре 'Без пересадок'")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.red)
                    } else {
                        Text("✅ ФИЛЬТР КОРРЕКТЕН: Все маршруты без пересадок")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.green)
                    }
                }
                
                if !filter.timeOptions.isEmpty {
                    Text("⏰ Фильтр времени активен: \(filter.timeOptions.count) диапазонов")
                        .font(.system(size: 12))
                        .foregroundColor(.blue)
                }
            }
            .padding(8)
            .background(Color.yellow.opacity(0.1))
            .cornerRadius(8)
            .padding(.horizontal, 16)
            
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(viewModel.filteredCarriers) { carrier in
                        VStack {
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
                            
                            VStack(alignment: .leading) {
                                Text("transferInfo: \(carrier.transferInfo ?? "nil")")
                                    .font(.system(size: 10))
                                    .foregroundColor(.gray)
                                Text("hasTransfer: \(carrier.hasTransfer ? "YES" : "NO")")
                                    .font(.system(size: 10))
                                    .foregroundColor(carrier.hasTransfer ? .red : .green)
                            }
                            .padding(.horizontal, 8)
                            .padding(.bottom, 4)
                        }
                        .background(Color.ypLightGray)
                        .cornerRadius(24)
                        .padding(.horizontal, 8)
                    }
                }
                .padding(.horizontal, 8)
            }
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
                .padding(.top, 237)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var shouldHideHeader: Bool {
        viewModel.loadError != nil
    }
    
    private var shouldShowBackButton: Bool {
        viewModel.loadError == nil && !viewModel.filteredCarriers.isEmpty
    }
    
    private var shouldHideTabBar: Bool {
        viewModel.loadError == nil && viewModel.filteredCarriers.isEmpty
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
