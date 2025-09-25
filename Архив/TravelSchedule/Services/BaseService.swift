//
//  BaseService.swift
//  TravelSchedule
//
//  Created by Наталья Черномырдина on 29.08.2025.
//

import Foundation
import OpenAPIRuntime

// MARK: - Base Service
class BaseService {
    
    // MARK: - Properties
    let client: Client
    let apikey: String

    // MARK: - Init
    init(client: Client, apikey: String) {
        self.client = client
        self.apikey = apikey
    }
}
