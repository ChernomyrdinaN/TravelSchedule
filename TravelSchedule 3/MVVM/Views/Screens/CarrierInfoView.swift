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
            
            .frame(height: 104)
          
            .cornerRadius(24)
            .scaledToFit()
        
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
            // Блок Email
            VStack(alignment: .leading, spacing: .zero) {
                Text("E-mail")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(.ypBlack)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                Link(
                    "i.lozgkina@yandex.ru",
                    destination: URL(string: "mailto:i.lozgkina@yandex.ru")!
                ).tint(.ypBlueUniversal)
                    .font(.system(size: 12, weight: .regular))
                    .frame(maxWidth: .infinity, alignment: .leading)
                  //  .foregroundColor(.ypBlueUniversal)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
            
            // Блок Телефон
            VStack(alignment: .leading, spacing: .zero) {
                Text("Телефон")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(.ypBlack)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Link("+7 (904) 329-27-71", destination: URL(string: "tel://+79043292771")!).tint(.ypBlueUniversal)
                    .font(.system(size: 12, weight: .regular))
                    .frame(maxWidth: .infinity, alignment: .leading)
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
