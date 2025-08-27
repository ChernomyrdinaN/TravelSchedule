//
//  ThreadStationsService.swift
//  TravelSchedule
//
//  Created by Наталья Черномырдина on 28.08.2025.
//

import OpenAPIRuntime
import OpenAPIURLSession
import Foundation

typealias ThreadStationsResponse = Components.Schemas.ThreadStationsResponse

protocol ThreadStationsServiceProtocol {
    func getThreadStations(
        uid: String,
        from: String?,
        to: String?,
        date: String?,
        showSystems: String?
    ) async throws -> ThreadStationsResponse
}

final class ThreadStationsService: ThreadStationsServiceProtocol {
    private let client: Client
    private let apikey: String
    
    init(client: Client, apikey: String) {
        self.client = client
        self.apikey = apikey
    }
    
    func getThreadStations(
        uid: String,
        from: String? = nil,
        to: String? = nil,
        date: String? = nil,
        showSystems: String? = nil
    ) async throws -> ThreadStationsResponse {
        let response = try await client.getThread(query: .init(
            apikey: apikey,
            uid: uid,
            from: from,
            to: to,
            date: date,
            show_systems: showSystems
        ))
        
        switch response {
        case .ok(let okResponse):
            switch okResponse.body {
            case .json(let threadResponse):
                return threadResponse
            }
        case .undocumented(statusCode: let statusCode, _):
            throw NSError(domain: "API Error", code: statusCode)
        }
    }
}
