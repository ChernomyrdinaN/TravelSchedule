//
//  FilterView.swift
//  TravelSchedule
//
//  Created by Наталья Черномырдина on 12.09.2025.
//

import SwiftUI

struct FilterView: View {
    @Binding var filter: CarrierFilter
    let applyFilters: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var viewModel: FilterViewModel
    
    init(filter: Binding<CarrierFilter>, applyFilters: @escaping () -> Void) {
        self._filter = filter
        self.applyFilters = applyFilters
        
        let viewModel = FilterViewModel(initialFilter: filter.wrappedValue) { newFilter in
            filter.wrappedValue = newFilter
            applyFilters()
        }
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            Color.ypWhite
                .ignoresSafeArea()
            
            VStack(spacing: .zero) {
                VStack(alignment: .leading, spacing: 24) {
                    timeFilterSection
                    transfersFilterSection
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 24)
                
                if viewModel.hasSelectedFilters {
                    applyButton
                        .padding(.top, 16)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 24)
                }
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
        .toolbar(.hidden, for: .tabBar)
    }
    
    private var timeFilterSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Время отправления")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.ypBlack)
            
            VStack(spacing: .zero) {
                ForEach(CarrierFilter.TimeOption.allCases, id: \.self) { option in
                    timeOptionRow(option: option)
                }
            }
            .background(Color.ypWhite)
            .cornerRadius(12)
        }
    }
    
    // MARK: - Private Methods
    private func timeOptionRow(option: CarrierFilter.TimeOption) -> some View {
        Button(action: {
            viewModel.toggleTimeOption(option)
        }) {
            HStack {
                Text(option.rawValue)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(.ypBlack)
                
                Spacer()
                
                if viewModel.filter.timeOptions.contains(option) {
                    Image("checkBoxOn")
                        .resizable()
                        .frame(width: 24, height: 24)
                } else {
                    Image("checkBoxOff")
                        .resizable()
                        .frame(width: 24, height: 24)
                }
            }
            .padding(.vertical, 12)
        }
    }
    
    private var transfersFilterSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Показывать варианты с\nпересадками")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.ypBlack)
            
            VStack(spacing: .zero) {
                transferOptionRow(title: "Да", isSelected: viewModel.filter.showTransfers == true) {
                    viewModel.setTransferFilter(true)
                }
                transferOptionRow(title: "Нет", isSelected: viewModel.filter.showTransfers == false) {
                    viewModel.setTransferFilter(false)
                }
            }
            .background(Color.ypWhite)
            .cornerRadius(12)
        }
    }
    
    private func transferOptionRow(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(.ypBlack)
                
                Spacer()
                
                if isSelected {
                    Image("radioButtonOn")
                        .resizable()
                        .frame(width: 24, height: 24)
                } else {
                    Image("radioButtonOff")
                        .resizable()
                        .frame(width: 24, height: 24)
                }
            }
            .padding(.vertical, 16)
        }
    }
    
    private var applyButton: some View {
        Button(action: {
            viewModel.applyFilter()
            dismiss()
        }) {
            Text("Применить")
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.ypWhiteUniversal)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(.ypBlueUniversal)
                .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
        .background(Color.ypLightGray)
        .cornerRadius(12)
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        CarrierListView(
            fromStation: "Москва",
            toStation: "Санкт-Петербург",
            navigationPath: .constant(NavigationPath()),
            filter: .constant(CarrierFilter())
        )
    }
}
