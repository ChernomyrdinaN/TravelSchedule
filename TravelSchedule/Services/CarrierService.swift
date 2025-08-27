//
//  CarrierService.swift
//  TravelSchedule
//
//  Created by Наталья Черномырдина on 28.08.2025.
//

import OpenAPIRuntime
import OpenAPIURLSession
import Foundation

typealias CarrierResponse = Components.Schemas.CarrierResponse

protocol CarrierServiceProtocol {
    func getCarrierInfo(code: String, system: String?) async throws -> CarrierResponse
}

final class CarrierService: CarrierServiceProtocol {
    private let client: Client
    private let apikey: String
    
    init(client: Client, apikey: String) {
        self.client = client
        self.apikey = apikey
    }
    
    func getCarrierInfo(
        code: String,
        system: String? = nil
    ) async throws -> CarrierResponse {
        let response = try await client.getCarrier(query: .init(
            apikey: apikey,
            code: code,
            system: system
        ))
        
        switch response {
        case .ok(let okResponse):
            switch okResponse.body {
            case .json(let carrierResponse):
                return carrierResponse
            }
        case .undocumented(statusCode: let statusCode, _):
            throw NSError(domain: "API Error", code: statusCode)
        }
    }
}
