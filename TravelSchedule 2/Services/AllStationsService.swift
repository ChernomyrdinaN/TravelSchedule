//
//   AllStationsService.swift
//  TravelSchedule
//
//  Created by Наталья Черномырдина on 28.08.2025.
//

import OpenAPIRuntime
import OpenAPIURLSession
import Foundation

typealias AllStationsResponse = Components.Schemas.AllStationsResponse

protocol AllStationsServiceProtocol {
    func getStationsList() async throws -> AllStationsResponse
}

final class AllStationsService: BaseService,AllStationsServiceProtocol {
    
    // MARK: - Public Methods
    func getStationsList() async throws -> AllStationsResponse {
        let output = try await client.getStationsList(query: .init(
            apikey: apikey,
            format: "json",
            lang: "ru_RU"
        ))
        
        switch output {
        case .ok(let ok):
            switch ok.body {
            case .json(let payload):
                // content-Type: application/json
                return payload
                
            case .html(let body):
                var data = Data()
                for try await chunk in body {
                    data.append(contentsOf: chunk)
                }
                return try JSONDecoder().decode(AllStationsResponse.self, from: data)
            }
        case .undocumented(statusCode: let statusCode, _):
            throw APIError.unknownStatus(statusCode)
        }
    }
}
