//
//  Carrier.swift
//  TravelSchedule
//
//  Created by Наталья Черномырдина on 12.09.2025.
//

import SwiftUI

struct Carrier: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let logo: String
    let transferInfo: String?
    let date: String
    let departureTime: String
    let travelTime: String
    let arrivalTime: String
    
    var hasTransfer: Bool {
        transferInfo != nil
    }
    
    var departureHour: Int {
        let components = departureTime.split(separator: ":")
        if components.count == 2, let hour = Int(components[0]) {
            return hour
        }
        return 0
    }
    
    var timeRange: CarrierFilter.TimeOption {
        let hour = departureHour
        switch hour {
        case 6..<12: return .morning
        case 12..<18: return .afternoon
        case 18..<24: return .evening
        default: return .night
        }
    }
}
