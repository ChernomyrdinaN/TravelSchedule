//
//  Station.swift
//  TravelSchedule
//
//  Created by Наталья Черномырдина on 08.09.2025.
//

import Foundation

// MARK: - Station
struct Station: Identifiable, Hashable, Sendable {
     let id = UUID()
     let name: String
     let code: String
     let transportType: String? 
}
