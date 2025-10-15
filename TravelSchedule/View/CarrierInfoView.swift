//
//  CarrierInfoView.swift
//  Created by Наталья Черномырдина on 23.09.2025.
//

import SwiftUI

struct CarrierInfoView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: CarrierInfoViewModel
    
    // MARK: - Init
    init(carrier: Carrier, apiClient: APIClient) {
        _viewModel = StateObject(wrappedValue: CarrierInfoViewModel(carrier: carrier, apiClient: apiClient))
    }
    
    // MARK: - Body
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
        .task {
            await viewModel.loadCarrierDetails()
        }
    }
}

// MARK: - Private Views
private extension CarrierInfoView {
    var carrierImage: some View {
        Group {
            if let url = viewModel.validLogoURL(viewModel.carrier.logo) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: 104)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                    case .failure:
                        placeholderLogo
                    @unknown default:
                        placeholderLogo
                    }
                }
            } else {
                placeholderLogo
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 104)
        .background(.ypWhiteUniversal)
        .cornerRadius(24)
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
    
    var carrierInfo: some View {
        VStack(alignment: .leading, spacing: .zero) {
            Text(viewModel.carrier.name)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.ypBlack)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            
            contactInfo
        }
    }
    
    var contactInfo: some View {
        VStack(spacing: .zero) {
            emailSection
            phoneSection
        }
    }
    
    var emailSection: some View {
        VStack(alignment: .leading, spacing: .zero) {
            Text("E-mail")
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(.ypBlack)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if let emailURL = viewModel.emailURL {
                Link(viewModel.carrierEmail, destination: emailURL)
                    .tint(.ypBlueUniversal)
                    .font(.system(size: 12, weight: .regular))
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Text(viewModel.carrierEmail)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.ypBlueUniversal)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 16)
    }
    
    var phoneSection: some View {
        VStack(alignment: .leading, spacing: .zero) {
            Text("Телефон")
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(.ypBlack)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if let phoneURL = viewModel.phoneURL {
                Link(viewModel.carrierPhone, destination: phoneURL)
                    .tint(.ypBlueUniversal)
                    .font(.system(size: 12, weight: .regular))
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Text(viewModel.carrierPhone)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.ypBlueUniversal)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 16)
    }
    
    var placeholderLogo: some View {
        Rectangle()
            .fill(Color.ypLightGray)
            .overlay(
                Image(systemName: "train.side.front.car")
                    .foregroundColor(.ypBlack)
            )
    }
}
