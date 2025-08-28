//
//  NearestSettlementService.swift
//  TravelSchedule
//
//  Created by Наталья Черномырдина on 28.08.2025.
//

import OpenAPIRuntime
import OpenAPIURLSession
import Foundation

typealias NearestSettlementResponse = Components.Schemas.NearestSettlementResponse

protocol NearestSettlementServiceProtocol {
    func getNearestSettlement(lat: Double, lng: Double, distance: Int?) async throws -> NearestSettlementResponse
}

final class NearestSettlementService: NearestSettlementServiceProtocol {
    
    // MARK: - Private Properties
    
    private let client: Client
    private let apikey: String
    
    // MARK: - Init
    
    init(client: Client, apikey: String) {
        self.client = client
        self.apikey = apikey
    }
    
    // MARK: - Public Methods
    
    func getNearestSettlement(
        lat: Double,
        lng: Double,
        distance: Int? = nil
    ) async throws -> NearestSettlementResponse {
        let response = try await client.getNearestSettlement(query: .init(
            apikey: apikey,
            lat: lat,
            lng: lng,
            distance: distance
        ))
        
        switch response {
        case .ok(let okResponse):
            switch okResponse.body {
            case .json(let settlementResponse):
                return settlementResponse
            }
        case .undocumented(statusCode: let statusCode, _):
            throw NSError(domain: "API Error", code: statusCode)
        }
    }
}
