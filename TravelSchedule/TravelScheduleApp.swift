//
//  TravelSchedulerApp.swift
//  TravelSchedule
//
//  Created by Наталья Черномырдина on 21.08.2025.
//

import SwiftUI

// MARK: - Travel Schedule App
@main
struct TravelScheduleApp: App {
    @StateObject private var container = DIContainer.shared

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(container.overlayCenter)
                .environmentObject(container.networkChecker)
        }
    }
}
