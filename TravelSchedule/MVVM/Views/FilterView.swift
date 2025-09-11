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
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            Color.ypWhite
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Text("Фильтры")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.ypBlack)
                    .padding(.top, 16)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        timeFilterSection
                        
                        transfersFilterSection
                        
                        if hasSelectedFilters {
                            applyButton
                                .padding(.top, 16)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 24)
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
    }
    
    // MARK: - Private Properties
    
    private var hasSelectedFilters: Bool {
        !filter.timeOptions.isEmpty || !filter.showTransfers
    }
    
    // MARK: - Subviews
    
    private var timeFilterSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Время отправления")
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.ypBlack)
            
            ForEach(CarrierFilter.TimeOption.allCases, id: \.self) { option in
                timeOptionRow(option: option)
            }
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
                
                if filter.timeOptions.contains(option) {
                    Image(systemName: "checkmark")
                        .foregroundColor(.ypBlue)
                }
            }
            .padding(.vertical, 8)
        }
    }
    
    private var transfersFilterSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Показывать варианты с пересадками")
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.ypBlack)
            
            // Вертикальное расположение кнопок как на скрине
            VStack(spacing: 8) {
                transferOptionRow(title: "Да", isSelected: filter.showTransfers) {
                    filter.showTransfers = true
                }
                
                transferOptionRow(title: "Нет", isSelected: !filter.showTransfers) {
                    filter.showTransfers = false
                }
            }
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
                    Image(systemName: "checkmark")
                        .foregroundColor(.ypBlue)
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
        }
    }
    
    private var applyButton: some View {
        Button(action: {
            applyFilters()
            dismiss()
        }) {
            Text("Применить")
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(.ypWhite)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(Color.ypBlue)
                .cornerRadius(12)
        }
    }
    
    // MARK: - Private Methods
    
    private func toggleTimeOption(_ option: CarrierFilter.TimeOption) {
        if filter.timeOptions.contains(option) {
            filter.timeOptions.removeAll { $0 == option }
        } else {
            filter.timeOptions.append(option)
        }
    }
}

#Preview {
    FilterView(
        filter: .constant(CarrierFilter()),
        applyFilters: {}
    )
}
