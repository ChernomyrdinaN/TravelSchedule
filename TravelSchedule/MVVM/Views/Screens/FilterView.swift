//
//  FilterView.swift
//  TravelSchedule
//
//  Created by Наталья Черномырдина on 12.09.2025.
//

import SwiftUI
import SwiftUI

struct FilterView: View {
    @Binding var filter: CarrierFilter
    let applyFilters: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var localFilter: CarrierFilter
    
    init(filter: Binding<CarrierFilter>, applyFilters: @escaping () -> Void) {
        self._filter = filter
        self.applyFilters = applyFilters
        self._localFilter = State(initialValue: filter.wrappedValue)
    }
    
    var body: some View {
        ZStack {
            Color.ypWhite
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 24) {
                    timeFilterSection
                    
                    transfersFilterSection
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 24)
                
                if hasSelectedFilters {
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
    
    // MARK: - Private Views
    private var timeFilterSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Время отправления")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.ypBlack)
            
            VStack(spacing: 0) {
                ForEach(CarrierFilter.TimeOption.allCases, id: \.self) { option in
                    timeOptionRow(option: option)
                }
            }
            .background(Color.ypWhite)
            .cornerRadius(12)
        }
    }
    
    private func timeOptionRow(option: CarrierFilter.TimeOption) -> some View {
        Button(action: {
            toggleTimeOption(option)
        }) {
            HStack {
                Text(option.rawValue)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(.ypBlack)
                
                Spacer()
                
                if localFilter.timeOptions.contains(option) {
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
            
            VStack(spacing: 0) {
                transferOptionRow(title: "Да", isSelected: localFilter.showTransfers == true) {
                    localFilter.showTransfers = true
                }
                transferOptionRow(title: "Нет", isSelected: localFilter.showTransfers == false) {
                    localFilter.showTransfers = false
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
            filter = localFilter
            applyFilters()
            dismiss()
        }) {
            Text("Применить")
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(.ypWhite1)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(Color.ypBlue)
                .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
        .background(Color.ypLightGray)
        .cornerRadius(12)
    }
    
    // MARK: - Private Properties
    private var hasSelectedFilters: Bool {
        !localFilter.timeOptions.isEmpty && localFilter.showTransfers != nil
    }
    
    // MARK: - Private Methods
    private func toggleTimeOption(_ option: CarrierFilter.TimeOption) {
        if localFilter.timeOptions.contains(option) {
            localFilter.timeOptions.removeAll { $0 == option }
        } else {
            localFilter.timeOptions.append(option)
        }
    }
}

#Preview {
    FilterView(
        filter: .constant(CarrierFilter()),
        applyFilters: {}
    )
}
