//
//  DIContainer.swift
//  TravelSchedule
//
//  Created by Наталья Черномырдина on 04.10.2025.
//

import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

// MARK: - Dependency Injection Container
final class DIContainer {
    @MainActor static let shared = DIContainer()
    
    let apiClient: APIClient
    
    private init() {
        let client = Client(
            serverURL: try! Servers.Server1.url(),
            transport: URLSessionTransport()
        )
        
        self.apiClient = APIClient(
            client: client,
            apiKey: Constants.yandexAPIKey
        )
    }
}
