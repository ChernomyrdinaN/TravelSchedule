//
//  DIContainer.swift
//  TravelSchedule
//
//  Created by Наталья Черномырдина on 04.10.2025.
//

import Foundation
import OpenAPIURLSession

// MARK: - Dependency Injection Container
final class DIContainer: ObservableObject {
    @MainActor static let shared = DIContainer()

    let apiClient: APIClient
    let networkChecker: NetworkChecker
    let overlayCenter: AppOverlayCenter

    private init() {
        let client: Client
        do {
            client = try Client(
                serverURL: Servers.Server1.url(),
                transport: URLSessionTransport()
            )
        } catch {
            fatalError("Failed to create Client: \(error)")
        }

        self.apiClient = APIClient(
            client: client,
            apiKey: Constants.yandexAPIKey
        )

        self.networkChecker = NetworkChecker()
        self.overlayCenter = AppOverlayCenter()
    }
}
