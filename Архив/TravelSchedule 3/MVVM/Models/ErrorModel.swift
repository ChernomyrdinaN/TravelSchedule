//
//  ErrorModel.swift
//  TravelSchedule
//
//  Created by Наталья Черномырдина on 13.09.2025.
//

import SwiftUI

struct ErrorModel {
    let type: ErrorType
    let title: String
    let imageName: String
    
    // MARK: - Error Type
    enum ErrorType {
        case noInternet
        case serverError
    }
    
    // MARK: - Static Instances
    static let error1 = ErrorModel(
        type: .noInternet,
        title: "Нет интернета",
        imageName: "error1"
    )
    
    static let error2 = ErrorModel(
        type: .serverError,
        title: "Ошибка сервера",
        imageName: "error2"
    )
}
