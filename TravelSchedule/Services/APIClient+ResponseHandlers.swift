//
//  APIClient+ResponseHandlers.swift
//  TravelSchedule
//
//  Created by Наталья Черномырдина on 05.10.2025.
//
import Foundation
import OpenAPIRuntime
import HTTPTypes

// MARK: - API Response Handlers Extension
extension APIClient {
    
    // MARK: - Nearest Stations Response
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
    
    // MARK: - All Stations Response
    func handleAllStationsResponse(_ response: Operations.getStationsList.Output) async throws -> Components.Schemas.AllStationsResponse {
        switch response {
        case .ok(let okResponse):
            switch okResponse.body {
            case .json(let payload):
                return payload
            case .html(let body):
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
    
    // MARK: - Carrier Response
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
    
    // MARK: - Nearest Settlement Response
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
    
    // MARK: - Schedule Between Stations Response
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
            switch statusCode {
            case 400:
                throw APIError.badRequest
            case 401:
                throw APIError.unauthorized
            case 404:
                return Components.Schemas.Segments(segments: [])
            case 500...599:
                throw APIError.serverError(statusCode)
            default:
                throw APIError.unknownStatus(statusCode)
            }
        @unknown default:
            throw APIError.invalidResponse
        }
    }
    
    // MARK: - Schedule On Station Response
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
    
    // MARK: - Thread Stations Response
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
    func handleHTMLResponse(_ body: HTTPBody) async throws -> Components.Schemas.AllStationsResponse {
        var data = Data()
        for try await chunk in body {
            data.append(contentsOf: chunk)
        }
        return try JSONDecoder().decode(Components.Schemas.AllStationsResponse.self, from: data)
    }
}
