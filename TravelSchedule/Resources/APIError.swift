//
//  APIError.swift
//  TravelSchedule
//
//  Created by Наталья Черномырдина on 29.08.2025.
//

import Foundation

// MARK: - API Error
enum APIError: Error {
    case unknownStatus(Int)
    case decodingError(Error)
    case invalidResponse
    case networkError(Error)
    case unauthorized
    case notFound
    case serverError(Int)
    case invalidStationCode
    case invalidRequest
}

// MARK: - Localized Error
extension APIError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .unknownStatus(let statusCode):
            return "Неизвестный статус код: \(statusCode)"
        case .decodingError(let error):
            return "Ошибка декодирования: \(error.localizedDescription)"
        case .invalidResponse:
            return "Неверный ответ сервера"
        case .networkError(let error):
            return "Сетевая ошибка: \(error.localizedDescription)"
        case .unauthorized:
            return "Не авторизован"
        case .notFound:
            return "Ресурс не найден"
        case .serverError(let statusCode):
            return "Ошибка сервера: \(statusCode)"
        case .invalidStationCode:
            return "Неверный код станции"
        case .invalidRequest:
            return "Неверный запрос"
        }
    }
}
