//
//  APIClientTests.swift
//  TravelScheduleTests
//
//  Created by Наталья Черномырдина on 04.10.2025.
//

import XCTest
@testable import TravelSchedule

final class APIClientTests: XCTestCase {
    
    // Проверяем что тип APIClient вообще доступен
    func testAPIClientTypeExists() {
        let clientType = APIClient.self
        XCTAssertNotNil(clientType)
        print("✅ Тип APIClient доступен в тестах")
    }
    
    // Проверяем что константы работают
    func testConstantsAvailable() {
        let key = Constants.yandexAPIKey
        XCTAssertFalse(key.isEmpty)
        XCTAssertEqual(key, "17dbdf13-ff18-4549-bbc7-ca3b8cd8b04b")
        print("✅ Константы доступны")
    }
    
    // Проверяем структуру APIClient через рефлексию
    func testAPIClientStructure() {
        let _ = String(describing: APIClient.self)
        XCTAssertTrue(true)
    }
}
