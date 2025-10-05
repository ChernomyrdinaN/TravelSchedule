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
        transportTypes: String? = nil,
        limit: Int? = nil
    ) async throws -> Components.Schemas.Segments {
        let response = try await client.getScheduleBetweenStations(query: .init(
            apikey: apiKey,
            from: from,
            to: to,
            date: date,
            transport_types: transportTypes,
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

// MARK: - City and Station Filters
extension APIClient {
    public func getRussianCities() async throws -> [Station] {
        let response = try await client.getStationsList(query: .init(
            apikey: apiKey,
            format: "json",
            lang: "ru_RU"
        ))
        return try await extractRussianCities(from: response)
    }
    
    public func getStationsForCity(_ city: String) async throws -> [Station] {
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
    
    private func filterRussianCities(from response: Components.Schemas.AllStationsResponse) -> [Station] {
        var cities: [Station] = []
        
        for country in response.countries ?? [] {
            if country.title == "Россия" {
                for region in country.regions ?? [] {
                    for settlement in region.settlements ?? [] {
                        if let cityName = settlement.title?.trimmingCharacters(in: .whitespacesAndNewlines),
                           !cityName.isEmpty,
                           cityName.count >= 2,
                           !cityName.lowercased().contains("деревня"),
                           !cityName.lowercased().contains("село"),
                           !cityName.lowercased().contains("поселок"),
                           !cityName.lowercased().contains("посёлок"),
                           !cityName.lowercased().contains("станица"),
                           !cityName.lowercased().contains("хутор") {
                            let city = Station(name: cityName)
                            cities.append(city)
                        }
                    }
                }
                break
            }
        }
        
        return Array(Set(cities)).sorted { $0.name < $1.name }
    }
    
    private func filterStationsForCity(from response: Components.Schemas.AllStationsResponse, city: String) -> [Station] {
        var stations: [Station] = []
        
        for country in response.countries ?? [] {
            for region in country.regions ?? [] {
                for settlement in region.settlements ?? [] {
                    if settlement.title == city {
                        for station in settlement.stations ?? [] {
                            if let stationName = station.title?.trimmingCharacters(in: .whitespacesAndNewlines),
                               !stationName.isEmpty {
                                let cleanName = stationName.replacingOccurrences(of: "\(city), ", with: "")
                                    .replacingOccurrences(of: "\(city),", with: "")
                                let stationModel = Station(name: cleanName.trimmingCharacters(in: .whitespacesAndNewlines))
                                stations.append(stationModel)
                            }
                        }
                        break
                    }
                }
            }
        }
        
        return stations.sorted { $0.name < $1.name }
    }
}
