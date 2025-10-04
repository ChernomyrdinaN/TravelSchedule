//
//  DIContainer.swift
//  TravelSchedule
//
//  Created by Наталья Черномырдина on 04.10.2025.
//

import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

final class DIContainer {
    @MainActor static let shared = DIContainer()
    
    let apiClient: APIClient
    
    private init() {
        let client = Client(
            serverURL: try! Servers.Server1.url(),
            transport: URLSessionTransport()
        )
        
        let apiKey = "your_api_key_here"
        let baseURL = URL(string: "https://api.rasp.yandex.net/v3.0/")!
        
        self.apiClient = APIClient(
            client: client,
            apiKey: apiKey,
            baseURL: baseURL
        )
    }
}
