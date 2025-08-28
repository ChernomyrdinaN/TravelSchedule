//
//  ScheduleBetweenStationsService.swift
//  TravelSchedule
//
//  Created by Наталья Черномырдина on 28.08.2025.
//

import OpenAPIRuntime
import OpenAPIURLSession
import Foundation

typealias SegmentsResponse = Components.Schemas.Segments

protocol ScheduleBetweenStationsServiceProtocol {
    func getScheduleBetweenStations(
        from: String,
        to: String,
        date: String?,
        transportTypes: String?,
        offset: Int?,
        limit: Int?,
        resultTimezone: String?,
        transfers: Bool?
    ) async throws -> SegmentsResponse
}

final class ScheduleBetweenStationsService: ScheduleBetweenStationsServiceProtocol {
    
    // MARK: - Private Properties
    
    private let client: Client
    private let apikey: String
    
    // MARK: - Init
    
    init(client: Client, apikey: String) {
        self.client = client
        self.apikey = apikey
    }
    
    // MARK: - Public Methods
    
    func getScheduleBetweenStations(
        from: String,
        to: String,
        date: String? = nil,
        transportTypes: String? = nil,
        offset: Int? = nil,
        limit: Int? = nil,
        resultTimezone: String? = nil,
        transfers: Bool? = nil
    ) async throws -> SegmentsResponse {
        let response = try await client.getScheduleBetweenStations(query: .init(
            apikey: apikey,
            from: from,
            to: to,
            date: date,
            transport_types: transportTypes,
            offset: offset,
            limit: limit,
            result_timezone: resultTimezone,
            transfers: transfers
        ))
        
        switch response {
        case .ok(let okResponse):
            switch okResponse.body {
            case .json(let segmentsResponse):
                return segmentsResponse
            }
        case .undocumented(statusCode: let statusCode, _):
            throw NSError(domain: "API Error", code: statusCode)
        }
    }
}
