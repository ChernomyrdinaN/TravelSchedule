//
//  APIClient+StructuredConcurrency.swift
//  TravelSchedule
//
//  Created by Наталья Черномырдина on 05.10.2025.
//

import Foundation

// MARK: - Structured Concurrency Extensions
extension APIClient {
    
    public func getStationOverview(stationCode: String) async throws -> (
        schedule: Components.Schemas.ScheduleResponse,
        nearest: Components.Schemas.Stations
    ) {

        async let scheduleTask = getScheduleOnStation(station: stationCode)
        async let nearestTask = getNearestStations(lat: 55.755826, lng: 37.617300, distance: 5)
        
        return try await (schedule: scheduleTask, nearest: nearestTask)
    }

    public func getBatchSchedules(stationCodes: [String]) async throws -> [String: Components.Schemas.ScheduleResponse] {
        return try await withThrowingTaskGroup(of: (String, Components.Schemas.ScheduleResponse).self) { group in
            var results = [String: Components.Schemas.ScheduleResponse]()
            
            for stationCode in stationCodes {
                group.addTask {
                    let schedule = try await self.getScheduleOnStation(station: stationCode)
                    return (stationCode, schedule)
                }
            }

            for try await (stationCode, schedule) in group {
                results[stationCode] = schedule
            }
            
            return results
        }
    }
}
