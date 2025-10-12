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
    public func getStationWithContinuation(stationCode: String) async throws -> Components.Schemas.ScheduleResponse {
        return try await withCheckedThrowingContinuation { continuation in
            simulateLegacyAPI(stationCode: stationCode) { result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let result = result {
                    continuation.resume(returning: result)
                } else {
                    continuation.resume(throwing: APIError.invalidResponse)
                }
            }
        }
    }
    
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
