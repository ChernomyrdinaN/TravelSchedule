//
//  Station.swift
//  TravelSchedule
//
//  Created by Наталья Черномырдина on 08.09.2025.
//

import Foundation

public struct Station: Identifiable, Hashable, Sendable {
    public let id = UUID()
    public let name: String
    public let code: String
    public let transportType: String? 
}
