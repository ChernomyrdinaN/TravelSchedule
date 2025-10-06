//
//  CarrierListView.swift
//  TravelSchedule
//
//  Created by Наталья Черномырдина on 12.09.2025.
//

import SwiftUI

struct CarrierListView: View {
    let fromStation: String
    let toStation: String
    @Binding var navigationPath: NavigationPath
    @Binding var filter: CarrierFilter
    
    @StateObject private var viewModel: CarrierListViewModel
    
    init(fromStation: String, toStation: String, navigationPath: Binding<NavigationPath>, filter: Binding<CarrierFilter>) {
        self.fromStation = fromStation
        self.toStation = toStation
        self._navigationPath = navigationPath
        self._filter = filter
        self._viewModel = StateObject(wrappedValue: CarrierListViewModel(
            fromStation: fromStation,
            toStation: toStation
        ))
    }
    
    var body: some View {
        ZStack {
            Color.ypWhite
                .ignoresSafeArea()
            
            VStack(spacing: .zero) {
                headerView
                    .padding(.top, 16)
                    .background(Color.ypWhite)
                
                if viewModel.filteredCarriers.isEmpty && !viewModel.isLoading {
                    emptyStateView
                } else {
                    carriersList
                }
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
                Button(action: {
                    navigationPath.removeLast()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.ypBlack)
                }
            }
        }
        
        .toolbar(.hidden, for: .tabBar)
        .task {
            await viewModel.loadCarriers()
        }
        .onChange(of: filter) {
            viewModel.applyCarrierFilter(filter)
        }
    }
    
    private var headerView: some View {
        Text("\(fromStation) → \(toStation)")
            .font(.system(size: 24, weight: .bold))
            .foregroundColor(.ypBlack)
            .lineLimit(2)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
    }
    
    private var carriersList: some View {
        ScrollView {
            if viewModel.isLoading {
                ProgressView()
                    .padding(.top, 20)
            } else {
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
    }
    
    private var clarifyTimeButton: some View {
        Button(action: {
            navigationPath.append(NavigationModels.filters)
        }) {
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
    
    private var emptyStateView: some View {
        VStack(spacing: .zero) {
            Text("Вариантов нет")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.ypBlack)
                .multilineTextAlignment(.center)
                .lineSpacing(0)
                .kerning(0)
                .padding(.top, 237)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var hasActiveFilters: Bool {
        !filter.timeOptions.isEmpty || filter.showTransfers != nil
    }
}
