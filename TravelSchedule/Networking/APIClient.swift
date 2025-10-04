//
//  APIClient.swift
//  TravelSchedule
//
//  Created by Наталья Черномырдина on 04.10.2025.
//

import Foundation
import OpenAPIRuntime
import HTTPTypes

public actor APIClient {
    private let client: Client
    private let apiKey: String
    private let baseURL: URL

    public init(client: Client, apiKey: String, baseURL: URL) {
        self.client = client
        self.apiKey = apiKey
        self.baseURL = baseURL
    }

    // MARK: - Nearest Stations
    public func getNearestStations(
        lat: Double,
        lng: Double,
        distance: Int
    ) async throws -> Components.Schemas.Stations {
        let response = try await client.getNearestStations(query: .init(
            apikey: apiKey,
            lat: lat,
            lng: lng,
            distance: distance
        ))
        return try handleNearestStationsResponse(response)
    }

    // MARK: - All Stations
    public func getAllStations() async throws -> Components.Schemas.AllStationsResponse {
        let response = try await client.getStationsList(query: .init(
            apikey: apiKey,
            format: "json",
            lang: "ru_RU"
        ))
        return try await handleAllStationsResponse(response)
    }

    // MARK: - Carrier Info
    public func getCarrierInfo(
        code: String,
        system: String? = nil
    ) async throws -> Components.Schemas.CarrierResponse {
        let response = try await client.getCarrier(query: .init(
            apikey: apiKey,
            code: code,
            system: system
        ))
        return try handleCarrierResponse(response)
    }

    // MARK: - Copyrights
    public func getCopyrights() async throws -> Components.Schemas.CopyrightsResponse {
        let response = try await client.getCopyrights(query: .init(
            apikey: apiKey
        ))
        return try handleCopyrightsResponse(response)
    }

    // MARK: - Nearest Settlement
    public func getNearestSettlement(
        lat: Double,
        lng: Double,
        distance: Int? = nil
    ) async throws -> Components.Schemas.NearestSettlementResponse {
        let response = try await client.getNearestSettlement(query: .init(
            apikey: apiKey,
            lat: lat,
            lng: lng,
            distance: distance
        ))
        return try handleNearestSettlementResponse(response)
    }

    // MARK: - Schedule Between Stations
    public func getScheduleBetweenStations(
        from: String,
        to: String,
        date: String? = nil,
        transportTypes: String? = nil,
        offset: Int? = nil,
        limit: Int? = nil,
        resultTimezone: String? = nil,
        transfers: Bool? = nil
    ) async throws -> Components.Schemas.Segments {
        let response = try await client.getScheduleBetweenStations(query: .init(
            apikey: apiKey,
            from: from,
            to: to,
            date: date,
            transport_types: transportTypes,
            offset: offset,
            limit: limit,
            result_timezone: resultTimezone,
            transfers: transfers
        ))
        return try handleScheduleBetweenStationsResponse(response)
    }

    // MARK: - Schedule On Station
    public func getScheduleOnStation(
        station: String,
        date: String? = nil,
        transportTypes: String? = nil,
        event: String? = nil,
        direction: String? = nil,
        system: String? = nil,
        resultTimezone: String? = nil
    ) async throws -> Components.Schemas.ScheduleResponse {
        let response = try await client.getScheduleOnStation(query: .init(
            apikey: apiKey,
            station: station,
            date: date,
            transport_types: transportTypes,
            event: event,
            direction: direction,
            system: system,
            result_timezone: resultTimezone
        ))
        return try handleScheduleOnStationResponse(response)
    }

    // MARK: - Thread Stations
    public func getThreadStations(
        uid: String,
        from: String? = nil,
        to: String? = nil,
        date: String? = nil,
        showSystems: String? = nil
    ) async throws -> Components.Schemas.ThreadStationsResponse {
        let response = try await client.getThread(query: .init(
            apikey: apiKey,
            uid: uid,
            from: from,
            to: to,
            date: date,
            show_systems: showSystems
        ))
        return try handleThreadStationsResponse(response)
    }
}

// MARK: - Private Helpers
private extension APIClient {
    
    // MARK: - Response Handlers
    
    func handleNearestStationsResponse(_ response: Operations.getNearestStations.Output) throws -> Components.Schemas.Stations {
        switch response {
        case .ok(let okResponse):
            switch okResponse.body {
            case .json(let stationsResponse):
                return stationsResponse
            @unknown default:
                throw APIError.invalidResponse
            }
        case .undocumented(statusCode: let statusCode, _):
            throw APIError.unknownStatus(statusCode)
        @unknown default:
            throw APIError.invalidResponse
        }
    }
    
    func handleAllStationsResponse(_ response: Operations.getStationsList.Output) async throws -> Components.Schemas.AllStationsResponse {
        switch response {
        case .ok(let okResponse):
            switch okResponse.body {
            case .json(let payload):
                return payload
            case .html(let body):
                // Для HTML ответа делаем отдельную async обработку
                return try await handleHTMLResponse(body)
            @unknown default:
                throw APIError.invalidResponse
            }
        case .undocumented(statusCode: let statusCode, _):
            throw APIError.unknownStatus(statusCode)
        @unknown default:
            throw APIError.invalidResponse
        }
    }
    
    func handleCarrierResponse(_ response: Operations.getCarrier.Output) throws -> Components.Schemas.CarrierResponse {
        switch response {
        case .ok(let okResponse):
            switch okResponse.body {
            case .json(let carrierResponse):
                return carrierResponse
            @unknown default:
                throw APIError.invalidResponse
            }
        case .undocumented(statusCode: let statusCode, _):
            throw APIError.unknownStatus(statusCode)
        @unknown default:
            throw APIError.invalidResponse
        }
    }
    
    func handleCopyrightsResponse(_ response: Operations.getCopyrights.Output) throws -> Components.Schemas.CopyrightsResponse {
        switch response {
        case .ok(let okResponse):
            switch okResponse.body {
            case .json(let copyrightsResponse):
                return copyrightsResponse
            @unknown default:
                throw APIError.invalidResponse
            }
        case .undocumented(statusCode: let statusCode, _):
            throw APIError.unknownStatus(statusCode)
        @unknown default:
            throw APIError.invalidResponse
        }
    }
    
    func handleNearestSettlementResponse(_ response: Operations.getNearestSettlement.Output) throws -> Components.Schemas.NearestSettlementResponse {
        switch response {
        case .ok(let okResponse):
            switch okResponse.body {
            case .json(let settlementResponse):
                return settlementResponse
            @unknown default:
                throw APIError.invalidResponse
            }
        case .undocumented(statusCode: let statusCode, _):
            throw APIError.unknownStatus(statusCode)
        @unknown default:
            throw APIError.invalidResponse
        }
    }
    
    func handleScheduleBetweenStationsResponse(_ response: Operations.getScheduleBetweenStations.Output) throws -> Components.Schemas.Segments {
        switch response {
        case .ok(let okResponse):
            switch okResponse.body {
            case .json(let segmentsResponse):
                return segmentsResponse
            @unknown default:
                throw APIError.invalidResponse
            }
        case .undocumented(statusCode: let statusCode, _):
            throw APIError.unknownStatus(statusCode)
        @unknown default:
            throw APIError.invalidResponse
        }
    }
    
    func handleScheduleOnStationResponse(_ response: Operations.getScheduleOnStation.Output) throws -> Components.Schemas.ScheduleResponse {
        switch response {
        case .ok(let okResponse):
            switch okResponse.body {
            case .json(let scheduleResponse):
                return scheduleResponse
            @unknown default:
                throw APIError.invalidResponse
            }
        case .undocumented(statusCode: let statusCode, _):
            throw APIError.unknownStatus(statusCode)
        @unknown default:
            throw APIError.invalidResponse
        }
    }
    
    func handleThreadStationsResponse(_ response: Operations.getThread.Output) throws -> Components.Schemas.ThreadStationsResponse {
        switch response {
        case .ok(let okResponse):
            switch okResponse.body {
            case .json(let threadResponse):
                return threadResponse
            @unknown default:
                throw APIError.invalidResponse
            }
        case .undocumented(statusCode: let statusCode, _):
            throw APIError.unknownStatus(statusCode)
        @unknown default:
            throw APIError.invalidResponse
        }
    }
    
    // MARK: - HTML Response Handler
    private func handleHTMLResponse(_ body: HTTPBody) async throws -> Components.Schemas.AllStationsResponse {
        var data = Data()
        for try await chunk in body {
            data.append(contentsOf: chunk)
        }
        return try JSONDecoder().decode(Components.Schemas.AllStationsResponse.self, from: data)
    }
}
