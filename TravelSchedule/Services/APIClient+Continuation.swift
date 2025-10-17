//
//  APIClient+Continuation.swift
//  TravelSchedule
//
//  Created by Наталья Черномырдина on 05.10.2025.
//

import Foundation
import OpenAPIRuntime

// MARK: - Continuation Wrappers
extension APIClient {    
    private func simulateLegacyAPI(stationCode: String, completion: @escaping (Components.Schemas.ScheduleResponse?, Error?) -> Void) {
        Task {
            do {
                let schedule = try await getScheduleOnStation(station: stationCode)
                completion(schedule, nil)
            } catch {
                completion(nil, error)
            }
        }
    }
}
