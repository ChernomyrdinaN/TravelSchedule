//
//  NavigationModels.swift
//  TravelSchedule
//
//  Created by Наталья Черномырдина on 12.09.2025.
//

import Foundation

// MARK: - Navigation
enum NavigationModels: Hashable, Sendable {
    case citySelection
    case stationSelection(city: String)
    case carrierList(from: Station, to: Station)
    case filters
}
