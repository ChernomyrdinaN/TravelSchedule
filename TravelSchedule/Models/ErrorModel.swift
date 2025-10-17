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
             .serverError
        case .notFound:
             .serverError
        case .serverError:
             .serverError
        case .badRequest, .invalidRequest:
             .serverError
        case .networkError(let error as URLError) where error.code == URLError.Code.notConnectedToInternet:
             .noInternet
        case .networkError, .invalidResponse, .invalidStationCode, .decodingError, .unknownStatus:
             .serverError
        }
    }
}

extension ErrorModel {
    static func fromAPIError(_ apiError: APIError) -> ErrorModel {
        return from(apiError: apiError)
    }
}
