//
//  ScheduleOnStationService.swift
//  TravelSchedule
//
//  Created by Наталья Черномырдина on 28.08.2025.
//

import OpenAPIRuntime
import OpenAPIURLSession
import Foundation

typealias ScheduleOnStationResponse = Components.Schemas.ScheduleResponse

protocol ScheduleOnStationServiceProtocol {
    func getScheduleOnStation(
        station: String,
        date: String?,
        transportTypes: String?,
        event: String?,
        direction: String?,
        system: String?,
        resultTimezone: String?
    ) async throws -> ScheduleOnStationResponse
}

final class ScheduleOnStationService: BaseService, ScheduleOnStationServiceProtocol {
    
    // MARK: - Public Methods
    func getScheduleOnStation(
        station: String,
        date: String? = nil,
        transportTypes: String? = nil,
        event: String? = nil,
        direction: String? = nil,
        system: String? = nil,
        resultTimezone: String? = nil
    ) async throws -> ScheduleOnStationResponse {
        let response = try await client.getScheduleOnStation(query: .init(
            apikey: apikey,
            station: station,
            date: date,
            transport_types: transportTypes,
            event: event,
            direction: direction,
            system: system,
            result_timezone: resultTimezone
        ))
        
        switch response {
        case .ok(let okResponse):
            switch okResponse.body {
            case .json(let scheduleResponse):
                return scheduleResponse
            }
        case .undocumented(statusCode: let statusCode, _):
            throw APIError.unknownStatus(statusCode)
        }
    }
}
