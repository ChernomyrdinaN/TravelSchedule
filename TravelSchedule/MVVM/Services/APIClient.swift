//
//  APIClient.swift
//  TravelSchedule
//
//  Created by Наталья Черномырдина on 04.10.2025.
//

import Foundation
import OpenAPIRuntime
import HTTPTypes

// MARK: - APIClient
public actor APIClient {
    private let client: Client
    private let apiKey: String
    
    public init(client: Client, apiKey: String) {
        self.client = client
        self.apiKey = apiKey
    }
}

// MARK: - API Methods
extension APIClient {
    public func getAllStations() async throws -> Components.Schemas.AllStationsResponse {
        let response = try await client.getStationsList(query: .init(
            apikey: apiKey,
            format: "json",
            lang: "ru_RU"
        ))
        return try await handleAllStationsResponse(response)
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
        date: String? = nil,
        transportTypes: [String]? = nil,
        limit: Int? = nil,
        transfers: Bool? = nil
    ) async throws -> [Components.Schemas.Segment] {
        let response = try await client.getScheduleBetweenStations(query: .init(
            apikey: apiKey,
            from: from,
            to: to,
            date: date,
            transport_types: transportTypes?.joined(separator: ","),
            limit: limit,
            transfers: transfers
        ))
        return try handleScheduleBetweenStations(response)
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
    
    private func handleScheduleBetweenStations(_ response: Operations.getScheduleBetweenStations.Output) throws -> [Components.Schemas.Segment] {
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
}

// MARK: - City and Station Filters
extension APIClient {
    func getRussianCities() async throws -> [Station] {
        let response = try await client.getStationsList(query: .init(
            apikey: apiKey,
            format: "json",
            lang: "ru_RU"
        ))
        return try await extractRussianCities(from: response)
    }
    
    func getStationsForCity(_ city: String) async throws -> [Station] {
        let response = try await client.getStationsList(query: .init(
            apikey: apiKey,
            format: "json",
            lang: "ru_RU"
        ))
        return try await extractStationsForCity(from: response, city: city)
    }
    
    private func extractRussianCities(from response: Operations.getStationsList.Output) async throws -> [Station] {
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
    
    private func extractStationsForCity(from response: Operations.getStationsList.Output, city: String) async throws -> [Station] {
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
    
    private func filterStationsForCity(from response: Components.Schemas.AllStationsResponse, city: String) -> [Station] {
        var result: [Station] = []
        
        for country in response.countries ?? [] {
            for region in country.regions ?? [] {
                for settlement in region.settlements ?? [] where settlement.title == city {
                    for st in settlement.stations ?? [] {
                        guard
                            let rawName = st.title?.trimmingCharacters(in: .whitespacesAndNewlines),
                            !rawName.isEmpty
                        else { continue }
                        
                        let cleanName = rawName
                            .replacingOccurrences(of: "\(city), ", with: "")
                            .replacingOccurrences(of: "\(city),", with: "")
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                        
                        let code = st.codes?.yandex_code
                        guard let code, !code.isEmpty, !cleanName.isEmpty else { continue }
                        
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
    
    private func filterRussianCities(from response: Components.Schemas.AllStationsResponse) -> [Station] {
        var result: [Station] = []
        
        for country in response.countries ?? [] {
            let isRussiaByTitle = (country.title?.localizedCaseInsensitiveContains("россия") ?? false)
            let isRussiaByCode = (country.codes?.yandex_code == "RU")
            if !(isRussiaByTitle || isRussiaByCode) { continue }
            
            for region in country.regions ?? [] {
                for settlement in region.settlements ?? [] {
                    guard let cityTitle = settlement.title?.trimmingCharacters(in: .whitespacesAndNewlines), !cityTitle.isEmpty else { continue }
                    
                    let cityCode = settlement.codes?.yandex_code
                    
                    if !(settlement.stations ?? []).isEmpty {
                        let station = Station(
                            name: cityTitle,
                            code: cityCode ?? cityTitle,
                            transportType: nil
                        )
                        result.append(station)
                    }
                }
            }
        }
        
        let unique = Dictionary(grouping: result, by: { !$0.code.isEmpty ? $0.code : $0.name }).compactMap { $0.value.first }
        return unique.sorted { $0.name < $1.name }
    }
}
