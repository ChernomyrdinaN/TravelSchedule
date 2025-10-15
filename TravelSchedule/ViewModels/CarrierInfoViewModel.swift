//
//  CarrierInfoViewModel.swift
//  TravelSchedule
//
//  Created by Наталья Черномырдина on 13.10.2025.
//

import Foundation
import SwiftUI

@MainActor
final class CarrierInfoViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var isLoading = false
    @Published var detailedCarrier: Components.Schemas.Carrier?
    
    // MARK: - Public Properties
    let carrier: Carrier
    let apiClient: APIClient
    
    // MARK: - Init
    init(carrier: Carrier, apiClient: APIClient) {
        self.carrier = carrier
        self.apiClient = apiClient
    }
}

// MARK: - Public Methods
extension CarrierInfoViewModel {
    func loadCarrierDetails() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let response = try await apiClient.getCarrierInfo(
                code: carrier.code,
                system: nil
            )
            self.detailedCarrier = response.carrier
        } catch {
            print("Ошибка загрузки деталей перевозчика: \(error)")
        }
    }
    
    func validLogoURL(_ logoString: String) -> URL? {
        guard !logoString.isEmpty,
              let url = URL(string: logoString),
              let scheme = url.scheme,
              scheme.hasPrefix("http") else {
            return nil
        }
        return url
    }
}

// MARK: - Computed Properties
extension CarrierInfoViewModel {
    var carrierEmail: String {
        guard let email = detailedCarrier?.email, !email.isEmpty else {
            return "—"
        }
        return email
    }
    
    var carrierPhone: String {
        guard let phone = detailedCarrier?.phone, !phone.isEmpty else {
            return "—"
        }
        return phone
    }
    
    var emailURL: URL? {
        guard carrierEmail != "—", carrierEmail.contains("@") else { return nil }
        return URL(string: "mailto:\(carrierEmail)")
    }
    
    var phoneURL: URL? {
        guard carrierPhone != "—" else { return nil }
        let cleanPhone = carrierPhone.filter { $0.isNumber }
        guard !cleanPhone.isEmpty else { return nil }
        return URL(string: "tel://\(cleanPhone)")
    }
}
