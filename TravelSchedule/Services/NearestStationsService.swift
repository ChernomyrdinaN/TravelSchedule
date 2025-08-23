//
//  NearestStationsService.swift
//  TravelSchedule
//
//  Created by Наталья Черномырдина on 22.08.2025.
//

// 1. Импортируем библиотеки:
import OpenAPIRuntime
import OpenAPIURLSession
import Foundation

// 2. Улучшаем читаемость кода — необязательный шаг
// Создаём псевдоним (typealias) для сгенерированного типа StationsResponse.
// Полное имя Components.Schemas.StationsResponse соответствует пути в openapi.yaml:
// components → schemas → StationsResponse
typealias NearestStationsResponse = Components.Schemas.StationsResponse

// Определяем протокол для нашего сервиса (хорошая практика для тестирования и гибкости)
protocol NearestStationsServiceProtocol {
    // Функция для получения станций, асинхронная и может выбросить ошибку
    func getNearestStations(lat: Double, lng: Double, distance: Int) async throws -> NearestStationsResponse
}

// Конкретная реализация сервиса
final class NearestStationsService: NearestStationsServiceProtocol {
    // Хранит экземпляр сгенерированного клиента
    private let client: Client
    // Хранит API-ключ (лучше передавать его извне, чем хранить прямо в сервисе)
    private let apikey: String
    
    init(client: Client, apikey: String) {
        self.client = client
        self.apikey = apikey
    }
    
    func getNearestStations(lat: Double, lng: Double, distance: Int) async throws -> NearestStationsResponse {
        // Вызываем функцию getNearestStations на ЭКЗЕМПЛЯРЕ сгенерированного клиента.
        // Имя функции и параметры 'query' напрямую соответствуют операции
        // 'getNearestStations' и её параметрам в openapi.yaml
        let response = try await client.getNearestStations(query: .init(
            apikey: apikey,     // Передаём API-ключ
            lat: Float(lat),    // Передаём широту
            lng: Float(lng),    // Передаём долготу 
            distance: distance  // Передаём дистанцию
        ))
        
        // Обрабатываем ответ (API возвращает StationsResponse, а не Station)
        switch response {
        case .ok(let okResponse):
            switch okResponse.body {
            case .json(let stationsResponse):
                // response.ok: Доступ к успешному ответу
                // .body: Получаем тело ответа
                // .json: Получаем объект из JSON в ожидаемом типе NearestStationsResponse
                return stationsResponse // Возвращаем весь ответ со списком станций
            }
        case .undocumented(statusCode: let statusCode, _):
            // Простая обработка ошибок
            throw NSError(domain: "API Error", code: statusCode)
        }
    }
}
