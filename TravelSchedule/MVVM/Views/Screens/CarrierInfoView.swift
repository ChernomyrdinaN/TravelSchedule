//
//  CarrierInfoView.swift
//  TravelSchedule
//
//  Created by Наталья Черномырдина on 23.09.2025.
//

import SwiftUI

struct CarrierInfoView: View {
    @Environment(\.dismiss) private var dismiss
    let carrier: Carrier
    
    var body: some View {
        ZStack {
            Color.ypWhite
                .ignoresSafeArea()
            
            VStack(spacing: .zero) {
                carrierImage
                carrierInfo
                Spacer()
            }
            .padding(.top, 16)
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle("Информация о перевозчике")
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
    }
    
    // MARK: - Carrier Image
    private var carrierImage: some View {
        Image(carrier.logo)
            .resizable()
            .scaledToFit()
            .frame(maxWidth: .infinity, maxHeight: 104)
            .background(.ypWhiteUniversal)
            .cornerRadius(24)
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
    }
    
    // MARK: - Carrier Info
    private var carrierInfo: some View {
        VStack(alignment: .leading, spacing: .zero) {
            Text(carrier.name)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.ypBlack)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            
            contactInfo
        }
    }
    
    // MARK: - Contact Info
    private var contactInfo: some View {
        VStack(spacing: .zero) {
            VStack(alignment: .leading, spacing: .zero) {
                Text("E-mail")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(.ypBlack)
                    .frame(maxWidth: .infinity, alignment: .leading)
             
                if let emailURL = URL(string: "mailto:i.lozgkina@yandex.ru") {
                    Link("i.lozgkina@yandex.ru", destination: emailURL)
                        .tint(.ypBlueUniversal)
                        .font(.system(size: 12, weight: .regular))
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    Text("i.lozgkina@yandex.ru")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.ypBlueUniversal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
            
            VStack(alignment: .leading, spacing: .zero) {
                Text("Телефон")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(.ypBlack)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if let phoneURL = URL(string: "tel://+79043292771") {
                    Link("+7 (904) 329-27-71", destination: phoneURL)
                        .tint(.ypBlueUniversal)
                        .font(.system(size: 12, weight: .regular))
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    Text("+7 (904) 329-27-71")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.ypBlueUniversal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        CarrierInfoView(carrier: Carrier.mockData[0])
    }
}
