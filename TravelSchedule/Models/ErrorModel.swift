//
//  ErrorModel.swift
//  TravelSchedule
//
//  Created by Наталья Черномырдина on 13.09.2025.
//

import SwiftUI

struct ErrorModel: Sendable {
    let type: ErrorType
    let title: String
    let imageName: String
    
    enum ErrorType {
        case noInternet
        case serverError
        case notFound
        case unauthorized
        case badRequest
    }
    
    static let serverError = ErrorModel(
        type: .serverError,
        title: "Ошибка сервера",
        imageName: "error1"
    )
    
    static let noInternet = ErrorModel(
        type: .noInternet,
        title: "Нет интернета",
        imageName: "error2"
    )
    
    static func from(apiError: APIError) -> ErrorModel {
        switch apiError {
        case .unauthorized:
            return .serverError
        case .notFound:
            return .serverError
        case .serverError:
            return .serverError
        case .badRequest, .invalidRequest:
            return .serverError
        case .networkError(let error as URLError) where error.code == URLError.Code.notConnectedToInternet:
            return .noInternet
        case .networkError, .invalidResponse, .invalidStationCode, .decodingError, .unknownStatus:
            return .serverError
        }
    }
}

extension ErrorModel {
    static func fromAPIError(_ apiError: APIError) -> ErrorModel {
        return from(apiError: apiError)
    }
}
