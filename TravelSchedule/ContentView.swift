//
//  ContentView.swift
//  TravelSchedule
//
//  Created by Наталья Черномырдина on 21.08.2025.
//

import SwiftUI
import OpenAPIURLSession

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
        .onAppear {
            testFetchNearestStations()
            testFetchStationsList()
            testFetchCarrierInfo()
            testFetchCopyrights()
            testFetchNearestSettlement()
            testFetchScheduleBetweenStations()
            testFetchScheduleOnStation()
            testFetchThreadStations()
        }
    }
    
    // MARK: - Private Methods
    private func formattedDate(daysFromNow: Int = 0) -> String {
        let calendar = Calendar.current
        let date = calendar.date(byAdding: .day, value: daysFromNow, to: Date()) ?? Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    private func testFetchNearestStations() {
        Task {
            do {
                guard let url = URL(string: "https://api.rasp.yandex.net") else {
                    print("❌ Ближайшие станции: Неверный URL")
                    return
                }
                let client = Client(serverURL: url, transport: URLSessionTransport())
                let service = NearestStationsService(client: client, apikey: Constants.yandexAPIKey)
                
                _ = try await service.getNearestStations(
                    lat: 59.864177,
                    lng: 30.319163,
                    distance: 50
                )
                
                print("✅ Ближайшие станции: Успех")
            } catch let error as APIError {
                print("❌ Ближайшие станции: \(error.localizedDescription)")
            } catch {
                print("❌ Ближайшие станции: Системная ошибка - \(error.localizedDescription)")
            }
        }
    }
    
    private func testFetchStationsList() {
        Task {
            do {
                guard let url = URL(string: "https://api.rasp.yandex.net") else {
                    print("❌ Список станций: Неверный URL")
                    return
                }
                let client = Client(serverURL: url, transport: URLSessionTransport())
                let service = AllStationsService(client: client, apikey: Constants.yandexAPIKey)
                
                _ = try await service.getStationsList()
                print("✅ Все станции: Успех")
            } catch let error as APIError {
                print("❌ Все станции: \(error.localizedDescription)")
            } catch {
                print("❌ Все станции: Системная ошибка - \(error.localizedDescription)")
            }
        }
    }
    
    private func testFetchCarrierInfo() {
        Task {
            do {
                guard let url = URL(string: "https://api.rasp.yandex.net") else {
                    print("❌ Информация о перевозчике: Неверный URL")
                    return
                }
                let client = Client(serverURL: url, transport: URLSessionTransport())
                let service = CarrierService(client: client, apikey: Constants.yandexAPIKey)
                
                _ = try await service.getCarrierInfo(
                    code: "104",
                    system: nil
                )
                
                print("✅ Информация о перевозчике: Успех")
            } catch let error as APIError {
                print("❌ Информация о перевозчике: \(error.localizedDescription)")
            } catch {
                print("❌ Информация о перевозчике: Системная ошибка - \(error.localizedDescription)")
            }
        }
    }
    
    private func testFetchCopyrights() {
        Task {
            do {
                guard let url = URL(string: "https://api.rasp.yandex.net") else {
                    print("❌ Копирайты: Неверный URL")
                    return
                }
                let client = Client(serverURL: url, transport: URLSessionTransport())
                let service = CopyrightsService(client: client, apikey: Constants.yandexAPIKey)
                
                _ = try await service.getCopyrights()
                print("✅ Копирайты: Успех")
            } catch let error as APIError {
                print("❌ Копирайты: \(error.localizedDescription)")
            } catch {
                print("❌ Копирайты: Системная ошибка - \(error.localizedDescription)")
            }
        }
    }
    
    private func testFetchNearestSettlement() {
        Task {
            do {
                guard let url = URL(string: "https://api.rasp.yandex.net") else {
                    print("❌ Ближайший населенный пункт: Неверный URL")
                    return
                }
                let client = Client(serverURL: url, transport: URLSessionTransport())
                let service = NearestSettlementService(client: client, apikey: Constants.yandexAPIKey)
                
                _ = try await service.getNearestSettlement(
                    lat: 55.755826,
                    lng: 37.617300,
                    distance: 50
                )
                
                print("✅ Ближайший населенный пункт: Успех")
            } catch let error as APIError {
                print("❌ Ближайший населенный пункт: \(error.localizedDescription)")
            } catch {
                print("❌ Ближайший населенный пункт: Системная ошибка - \(error.localizedDescription)")
            }
        }
    }
    
    private func testFetchScheduleBetweenStations() {
        Task {
            do {
                guard let url = URL(string: "https://api.rasp.yandex.net") else {
                    print("❌ Расписание между станциями: Неверный URL")
                    return
                }
                
                let client = Client(serverURL: url, transport: URLSessionTransport())
                let service = ScheduleBetweenStationsService(client: client, apikey: Constants.yandexAPIKey)
                
                _ = try await service.getScheduleBetweenStations(
                    from: "s2000001",
                    to: "s9601840",
                    date: formattedDate(),
                    transportTypes: "train",
                    limit: 5
                )
                
                print("✅ Расписание между станциями: Успех")
            } catch let error as APIError {
                print("❌ Расписание между станциями: \(error.localizedDescription)")
            } catch {
                print("❌ Расписание между станциями: Системная ошибка - \(error.localizedDescription)")
            }
        }
    }
    
    private func testFetchScheduleOnStation() {
        Task {
            do {
                guard let url = URL(string: "https://api.rasp.yandex.net") else {
                    print("❌ Расписание на станции: Неверный URL")
                    return
                }
                let client = Client(serverURL: url, transport: URLSessionTransport())
                let service = ScheduleOnStationService(client: client, apikey: Constants.yandexAPIKey)
                
                _ = try await service.getScheduleOnStation(
                    station: "s2000001",
                    date: formattedDate(),
                    transportTypes: "train",
                    event: "departure"
                )
                
                print("✅ Расписание на станции: Успех")
            } catch let error as APIError {
                print("❌ Расписание на станции: \(error.localizedDescription)")
            } catch {
                print("❌ Расписание на станции: Системная ошибка - \(error.localizedDescription)")
            }
        }
    }
    
    private func testFetchThreadStations() {
        Task {
            do {
                guard let url = URL(string: "https://api.rasp.yandex.net") else {
                    print("❌ Станции маршрута: Неверный URL")
                    return
                }
                
                let client = Client(serverURL: url, transport: URLSessionTransport())
                let threadService = ThreadStationsService(client: client, apikey: Constants.yandexAPIKey)
                
                _ = try await threadService.getThreadStations(
                    uid: "732YA_2_2",
                    from: "s2000001",
                    to: "s2004001",
                    date: formattedDate()
                )
                
                print("✅ Станции маршрута: Успех")
            } catch let error as APIError {
                print("❌ Станции маршрута: \(error.localizedDescription)")
            } catch {
                print("❌ Станции маршрута: Системная ошибка - \(error.localizedDescription)")
            }
        }
    }
}
