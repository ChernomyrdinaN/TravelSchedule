//
//  APIClient.swift
//  TravelSchedule
//
//  Created by Наталья Черномырдина on 05.10.2025.
//

import Foundation
import OpenAPIRuntime
import HTTPTypes

public actor APIClient {
    private let client: Client
    private let apiKey: String
    
    public init(client: Client, apiKey: String) {
        self.client = client
        self.apiKey = apiKey
    }
}

// MARK: - Public Methods
extension APIClient {
    public func getAllStations() async throws -> Components.Schemas.AllStationsResponse {
        let response = try await client.getStationsList(query: .init(
            apikey: apiKey,
            format: "json",
            lang: "ru_RU"
        ))
        return try await handleAllStationsResponse(response)
    }
    
    public func getStationsForCity(_ city: String) async throws -> [Station] {
        let response = try await client.getStationsList(query: .init(
            apikey: apiKey,
            format: "json",
            lang: "ru_RU"
        ))
        return try await extractStationsForCity(from: response, city: city)
    }
    
    public func getRussianCities() async throws -> [Station] {
        let response = try await client.getStationsList(query: .init(
            apikey: apiKey,
            format: "json",
            lang: "ru_RU"
        ))
        return try await extractRussianCities(from: response)
    }
    
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
    
    public func getNearestSettlement(
        lat: Double,
        lng: Double,
        distance: Int
    ) async throws -> Components.Schemas.NearestSettlementResponse {
        let response = try await client.getNearestSettlement(query: .init(
            apikey: apiKey,
            lat: lat,
            lng: lng,
            distance: distance
        ))
        return try handleNearestSettlementResponse(response)
    }
    
    public func getScheduleBetweenStations(
        from: String,
        to: String,
        date: String,
        transportTypes: [String]? = nil,
        limit: Int? = nil
    ) async throws -> Components.Schemas.Segments {
        let response = try await client.getScheduleBetweenStations(query: .init(
            apikey: apiKey,
            from: from,
            to: to,
            date: date,
            transport_types: transportTypes?.joined(separator: ","),
            limit: limit
        ))
        return try handleScheduleBetweenStationsResponse(response)
    }
    
    public func getScheduleOnStation(
        station: String,
        date: String? = nil,
        transportTypes: String? = nil,
        event: String? = nil
    ) async throws -> Components.Schemas.ScheduleResponse {
        let response = try await client.getScheduleOnStation(query: .init(
            apikey: apiKey,
            station: station,
            date: date,
            transport_types: transportTypes,
            event: event
        ))
        return try handleScheduleOnStationResponse(response)
    }
    
    public func getThread(
        uid: String,
        from: String? = nil,
        to: String? = nil,
        date: String? = nil
    ) async throws -> Components.Schemas.ThreadStationsResponse {
        let response = try await client.getThread(query: .init(
            apikey: apiKey,
            uid: uid,
            from: from,
            to: to,
            date: date
        ))
        return try handleThreadStationsResponse(response)
    }
}

// MARK: - Private Methods
private extension APIClient {
    func handleScheduleBetweenStations(_ response: Operations.getScheduleBetweenStations.Output) throws -> [Components.Schemas.Segment] {
        switch response {
        case .ok(let okResponse):
            switch okResponse.body {
            case .json(let payload):
                return payload.segments ?? []
            @unknown default:
                throw APIError.invalidResponse
            }
        case .undocumented(statusCode: let statusCode, _):
            throw APIError.unknownStatus(statusCode)
        @unknown default:
            throw APIError.invalidResponse
        }
    }
    
    func extractRussianCities(from response: Operations.getStationsList.Output) async throws -> [Station] {
        switch response {
        case .ok(let okResponse):
            switch okResponse.body {
            case .json(let payload):
                return filterRussianCities(from: payload)
            case .html(let body):
                let data = try await handleHTMLResponse(body)
                return filterRussianCities(from: data)
            @unknown default:
                throw APIError.invalidResponse
            }
        case .undocumented(statusCode: let statusCode, _):
            throw APIError.unknownStatus(statusCode)
        @unknown default:
            throw APIError.invalidResponse
        }
    }
    
    func filterRussianCities(from response: Components.Schemas.AllStationsResponse) -> [Station] {
        var result: [Station] = []
        
        for country in response.countries ?? [] {
            let isRussiaByTitle = (country.title?.localizedCaseInsensitiveContains("россия") ?? false)
            let isRussiaByCode = (country.codes?.yandex_code == "RU")
            if !(isRussiaByTitle || isRussiaByCode) { continue }
            
            for region in country.regions ?? [] {
                for settlement in region.settlements ?? [] {
                    guard let cityTitle = settlement.title?.trimmingCharacters(in: .whitespacesAndNewlines),
                          !cityTitle.isEmpty else { continue }
                    
                    if let firstRailwayStation = settlement.stations?.first(where: {
                        $0.transport_type == "train" || $0.transport_type == "suburban"
                    }) {
                        guard let stationCode = firstRailwayStation.codes?.yandex_code,
                              !stationCode.isEmpty else { continue }
                        
                        let station = Station(
                            name: cityTitle,
                            code: stationCode,
                            transportType: firstRailwayStation.transport_type
                        )
                        result.append(station)
                    }
                }
            }
        }
        
        let unique = Dictionary(grouping: result, by: { $0.code }).compactMap { $0.value.first }
        return unique.sorted { $0.name < $1.name }
    }
    
    func extractStationsForCity(from response: Operations.getStationsList.Output, city: String) async throws -> [Station] {
        switch response {
        case .ok(let okResponse):
            switch okResponse.body {
            case .json(let payload):
                return filterStationsForCity(from: payload, city: city)
            case .html(let body):
                let data = try await handleHTMLResponse(body)
                return filterStationsForCity(from: data, city: city)
            @unknown default:
                throw APIError.invalidResponse
            }
        case .undocumented(statusCode: let statusCode, _):
            throw APIError.unknownStatus(statusCode)
        @unknown default:
            throw APIError.invalidResponse
        }
    }
    
    func filterStationsForCity(from response: Components.Schemas.AllStationsResponse, city: String) -> [Station] {
        var result: [Station] = []
        
        for country in response.countries ?? [] {
            for region in country.regions ?? [] {
                for settlement in region.settlements ?? [] where settlement.title == city {
                    for st in settlement.stations ?? [] {
                        
                        guard st.transport_type == "train" || st.transport_type == "suburban",
                              let rawName = st.title?.trimmingCharacters(in: .whitespacesAndNewlines),
                              !rawName.isEmpty,
                              let code = st.codes?.yandex_code,
                              !code.isEmpty else {
                            continue
                        }
                        
                        let cleanName = rawName
                            .replacingOccurrences(of: "\(city), ", with: "")
                            .replacingOccurrences(of: "\(city),", with: "")
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                        
                        guard !cleanName.isEmpty else { continue }
                        
                        let model = Station(
                            name: cleanName,
                            code: code,
                            transportType: st.transport_type
                        )
                        result.append(model)
                    }
                    break
                }
            }
        }
        
        let unique = Dictionary(grouping: result, by: { $0.code }).compactMap { $0.value.first }
        return unique.sorted { $0.name < $1.name }
    }
}
