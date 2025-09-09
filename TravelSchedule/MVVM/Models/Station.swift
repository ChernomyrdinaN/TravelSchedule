//
//  Station.swift
//  TravelSchedule
//
//  Created by Наталья Черномырдина on 08.09.2025.
//

import Foundation

struct Station: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let station: String
}

// Пример данных для тестирования
let mockStations = [
    Station(name: "Москва", station: "Курский вокзал"),
    Station(name: "Санкт-Петербург", station: "Балтийский вокзал"),
    Station(name: "Нижний Новгород", station: "Московский вокзал"),
    Station(name: "Казань", station: "Центральный вокзал"),
    Station(name: "Екатеринбург", station: "Свердловский вокзал")
]
