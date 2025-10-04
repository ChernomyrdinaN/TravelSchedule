//
//  APIClientTests.swift
//  TravelScheduleTests
//
//  Created by Наталья Черномырдина on 04.10.2025.
//

import XCTest
@testable import TravelSchedule

final class MinimalTests: XCTestCase {
    
    func testBasicStructuresExist() {
    
        let station = Station(name: "Тест")
        XCTAssertEqual(station.name, "Тест")
        print("✅ Базовая структура Station работает")
    }
    
    @MainActor func testViewModelCreation() {
    
        let _ = MainViewModel()
        XCTAssertTrue(true)
        print("✅ MainViewModel создается")
    }
}
