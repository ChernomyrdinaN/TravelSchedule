//
//  CopyrightsService.swift
//  TravelSchedule
//
//  Created by Наталья Черномырдина on 28.08.2025.
//

import OpenAPIRuntime
import OpenAPIURLSession
import Foundation

typealias CopyrightsResponse = Components.Schemas.CopyrightsResponse

protocol CopyrightsServiceProtocol {
    func getCopyrights() async throws -> CopyrightsResponse
}

final class CopyrightsService: CopyrightsServiceProtocol {
    
    // MARK: - Private Properties
    
    private let client: Client
    private let apikey: String
    
    // MARK: - Init
    
    init(client: Client, apikey: String) {
        self.client = client
        self.apikey = apikey
    }
    
    // MARK: - Public Methods
    
    func getCopyrights() async throws -> CopyrightsResponse {
        let response = try await client.getCopyrights(query: .init(
            apikey: apikey
        ))
        
        switch response {
        case .ok(let okResponse):
            switch okResponse.body {
            case .json(let copyrightsResponse):
                return copyrightsResponse
            }
        case .undocumented(statusCode: let statusCode, _):
            throw NSError(domain: "API Error", code: statusCode)
        }
    }
}
