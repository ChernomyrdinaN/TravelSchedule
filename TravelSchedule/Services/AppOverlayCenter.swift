//
//  AppOverlayCenter.swift
//  TravelSchedule
//
//  Created by Наталья Черномырдина on 15.10.2025.
//

import Foundation

// MARK: - App Overlay Center
final class AppOverlayCenter: ObservableObject {
    @Published var isInternetDown: Bool = false
    @Published var serverErrorToShow: APIError? = nil

    func showServerError(_ err: APIError) { serverErrorToShow = err }
    func clearServerError() { serverErrorToShow = nil }
}
