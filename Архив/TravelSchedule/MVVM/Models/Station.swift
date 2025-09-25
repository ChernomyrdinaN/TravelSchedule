//
//  Station.swift
//  TravelSchedule
//
//  Created by Наталья Черномырдина on 08.09.2025.
//

import Foundation

struct Station: Identifiable, Hashable {
    let id = UUID()
    let name: String
    
    // MARK: - Mock Data
    static let mockData = [
        Station(name: "Москва"),
        Station(name: "Санкт-Петербург"),
        Station(name: "Сочи"),
        Station(name: "Горный воздух"),
        Station(name: "Краснодар"),
        Station(name: "Казань"),
        Station(name: "Омск"),
        Station(name: "Екатеринбург"),
        Station(name: "Нижний Новгород"),
        Station(name: "Новосибирск")
    ]
    
    // MARK: - Station Methods
        static func mockStations(for city: String) -> [Station] {
            switch city {
            case "Москва":
                return [
                    Station(name: "Киевский вокзал"),
                    Station(name: "Курский вокзал"),
                    Station(name: "Ярославский вокзал"),
                    Station(name: "Белорусский вокзал"),
                    Station(name: "Савеловский вокзал"),
                    Station(name: "Ленинградский вокзал")
                ]
            case "Санкт-Петербург":
                return [
                    Station(name: "Балтийский вокзал"),
                    Station(name: "Витебский вокзал"),
                    Station(name: "Ладожский вокзал"),
                    Station(name: "Московский вокзал"),
                    Station(name: "Финляндский вокзал")
                ]
            case "Сочи":
                return [
                    Station(name: "Сочи Центральный"),
                    Station(name: "Адлер")
                ]
            case "Казань":
                return [
                    Station(name: "Казань Главный"),
                    Station(name: "Восстания")
                ]
            case "Екатеринбург":
                return [
                    Station(name: "Екатеринбург Пассажирский"),
                    Station(name: "Сортировочный")
                ]
            case "Нижний Новгород":
                return [
                    Station(name: "Московский вокзал"),
                    Station(name: "Сортировочный")
                ]
            case "Новосибирск":
                return [
                    Station(name: "Новосибирск Главный"),
                    Station(name: "Инская")
                ]
            case "Краснодар":
                return [
                    Station(name: "Краснодар I"),
                    Station(name: "Краснодар II")
                ]
            default:
                return []
            }
        }
    }
