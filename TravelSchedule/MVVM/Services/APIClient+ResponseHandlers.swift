//
//  APIClient+ResponseHandlers.swift
//  TravelSchedule
//
//  Created by Наталья Черномырдина on 05.10.2025.
//

import Foundation
import OpenAPIRuntime
import HTTPTypes

// MARK: - Response Handlers
extension APIClient {
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
    
    func handleHTMLResponse(_ body: HTTPBody) async throws -> Components.Schemas.AllStationsResponse {
        var data = Data()
        for try await chunk in body {
            data.append(contentsOf: chunk)
        }
        return try JSONDecoder().decode(Components.Schemas.AllStationsResponse.self, from: data)
    }
}
