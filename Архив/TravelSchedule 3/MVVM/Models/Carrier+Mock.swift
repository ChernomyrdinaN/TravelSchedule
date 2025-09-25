//
//  Carrier+Mock.swift
//  TravelSchedule
//
//  Created by Наталья Черномырдина on 17.09.2025.
//

import Foundation

extension Carrier {
    
    // MARK: - Mock Data
    static let mockData: [Carrier] = [
        Carrier(
            name: "ОАО РЖД",
            logo: "BrandIcon1",
            transferInfo: "С пересадкой в Костроме",
            date: "14 января",
            departureTime: "22:30",
            travelTime: "20 часов",
            arrivalTime: "08:15"
        ),
        Carrier(
            name: "ФГК",
            logo: "BrandIcon2",
            transferInfo: nil,
            date: "15 января",
            departureTime: "01:15",
            travelTime: "9 часов",
            arrivalTime: "09:00"
        ),
        Carrier(
            name: "Урал логистика",
            logo: "BrandIcon1",
            transferInfo: nil,
            date: "16 января",
            departureTime: "12:30",
            travelTime: "9 часов",
            arrivalTime: "21:00"
        ),
        Carrier(
            name: "ОАО РЖД",
            logo: "BrandIcon1",
            transferInfo: "С пересадкой в Костроме",
            date: "17 января",
            departureTime: "22:30",
            travelTime: "20 часов",
            arrivalTime: "08:15"
        )
    ]
}
