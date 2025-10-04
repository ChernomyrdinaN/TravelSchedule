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
}

// MARK: - Basic API Methods
extension APIClient {
    
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
