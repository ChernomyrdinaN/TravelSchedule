//
//  NearestStationsService.swift
//  TravelSchedule
//
//  Created by Наталья Черномырдина on 22.08.2025.
//

import OpenAPIRuntime
import OpenAPIURLSession
import Foundation

typealias NearestStationsResponse = Components.Schemas.Stations

protocol NearestStationsServiceProtocol {
    func getNearestStations(lat: Double, lng: Double, distance: Int) async throws -> NearestStationsResponse
}

final class NearestStationsService: NearestStationsServiceProtocol {
    
    // MARK: - Private Properties
    
    private let client: Client
    private let apikey: String
    
    // MARK: - Init
    
    init(client: Client, apikey: String) {
        self.client = client
        self.apikey = apikey
    }
    
    // MARK: - Public Methods
    
    func getNearestStations(lat: Double, lng: Double, distance: Int) async throws -> NearestStationsResponse {
        let response = try await client.getNearestStations(query: .init(
            apikey: apikey,
            lat: lat,
            lng: lng,
            distance: distance
        ))
        
        switch response {
        case .ok(let okResponse):
            switch okResponse.body {
            case .json(let stationsResponse):
                return stationsResponse
            }
        case .undocumented(statusCode: let statusCode, _):
            throw NSError(domain: "API Error", code: statusCode)
        }
    }
}
