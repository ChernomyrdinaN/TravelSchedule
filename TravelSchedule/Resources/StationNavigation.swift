//
//  StationNavigation.swift
//  TravelSchedule
//
//  Created by Наталья Черномырдина on 12.09.2025.
//

import Foundation

enum StationNavigation: Hashable {
    case citySelection
    case stationSelection(city: String)
    case carrierList(from: String, to: String)
    case filters
}
