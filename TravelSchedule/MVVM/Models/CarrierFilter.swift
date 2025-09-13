//
//  CarrierFilter.swift
//  TravelSchedule
//
//  Created by Наталья Черномырдина on 12.09.2025.
//

import Foundation

struct CarrierFilter: Hashable {
    var timeOptions: [TimeOption] = []
    var showTransfers: Bool? = nil
    
    enum TimeOption: String, CaseIterable, Hashable {
        case morning = "Утро 06:00 - 12:00"
        case afternoon = "День 12:00 - 18:00"
        case evening = "Вечер 18:00 - 00:00"
        case night = "Ночь 00:00 - 06:00"
    }
}
