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
    
    static let mockData = [
        Station(name: "Москва"),
        Station(name: "Санкт-Петербург"),
        Station(name: "Сочи"),
        Station(name: "Горный воздух"),
        Station(name: "Краснодар"),
        Station(name: "Казань"),
        Station(name: "Омск"),
        Station(name: "Екатеринбург"),
        Station(name: "Нижний Новгород"),
        Station(name: "Новосибирск")
    ]
}
