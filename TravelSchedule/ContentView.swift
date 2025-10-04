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
    
    // MARK: - APIClient Tests
    
    private func testFetchNearestStations() {
        Task {
            do {
                guard let url = URL(string: "https://api.rasp.yandex.net") else {
                    print("❌ Ближайшие станции: Неверный URL")
                    return
                }
                let client = Client(serverURL: url, transport: URLSessionTransport())
                let apiClient = APIClient(
                    client: client,
                    apiKey: Constants.yandexAPIKey,
                    baseURL: URL(string: "https://api.rasp.yandex.net/v3.0")!
                )
                
                let stations = try await apiClient.getNearestStations(
                    lat: 59.864177,
                    lng: 30.319163,
                    distance: 50
                )
                
                print("✅ Ближайшие станции: Успех (APIClient) - \(stations.stations?.count ?? 0) станций")
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
                let apiClient = APIClient(
                    client: client,
                    apiKey: Constants.yandexAPIKey,
                    baseURL: URL(string: "https://api.rasp.yandex.net/v3.0")!
                )
                
                let stations = try await apiClient.getAllStations()
                print("✅ Все станции: Успех (APIClient) - стран: \(stations.countries?.count ?? 0)")
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
                let apiClient = APIClient(
                    client: client,
                    apiKey: Constants.yandexAPIKey,
                    baseURL: URL(string: "https://api.rasp.yandex.net/v3.0")!
                )
                
                let carrier = try await apiClient.getCarrierInfo(code: "104", system: nil)
                print("✅ Информация о перевозчике: Успех (APIClient) - \(carrier.carrier?.title ?? "No title")")
            } catch let error as APIError {
                print("❌ Информация о перевозчике: \(error.localizedDescription)")
            } catch {
                print("❌ Информация о перевозчике: Системная ошибка - \(error.localizedDescription)")
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
                let apiClient = APIClient(
                    client: client,
                    apiKey: Constants.yandexAPIKey,
                    baseURL: URL(string: "https://api.rasp.yandex.net/v3.0")!
                )
                
                let settlement = try await apiClient.getNearestSettlement(
                    lat: 55.755826,
                    lng: 37.617300,
                    distance: 50
                )
                print("✅ Ближайший населенный пункт: Успех (APIClient) - \(settlement.title ?? "No title")")
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
                let apiClient = APIClient(
                    client: client,
                    apiKey: Constants.yandexAPIKey,
                    baseURL: URL(string: "https://api.rasp.yandex.net/v3.0")!
                )
                
                let schedule = try await apiClient.getScheduleBetweenStations(
                    from: "s2000001",
                    to: "s9601840",
                    date: formattedDate(),
                    transportTypes: "train",
                    limit: 5
                )
                print("✅ Расписание между станциями: Успех (APIClient) - \(schedule.segments?.count ?? 0) сегментов")
            } catch let error as APIError {
                print("❌ Расписание между станциями: \(error.localizedDescription)")
            } catch {
                print("❌ Расписание между станций: Системная ошибка - \(error.localizedDescription)")
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
                let apiClient = APIClient(
                    client: client,
                    apiKey: Constants.yandexAPIKey,
                    baseURL: URL(string: "https://api.rasp.yandex.net/v3.0")!
                )
                
                let schedule = try await apiClient.getScheduleOnStation(
                    station: "s2000001",
                    date: formattedDate(),
                    transportTypes: "train",
                    event: "departure"
                )
                print("✅ Расписание на станции: Успех (APIClient) - \(schedule.schedule?.count ?? 0) расписаний")
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
                let apiClient = APIClient(
                    client: client,
                    apiKey: Constants.yandexAPIKey,
                    baseURL: URL(string: "https://api.rasp.yandex.net/v3.0")!
                )
                
                let thread = try await apiClient.getThreadStations(
                    uid: "732YA_2_2",
                    from: "s2000001",
                    to: "s2004001",
                    date: formattedDate()
                )
                print("✅ Станции маршрута: Успех (APIClient) - остановок: \(thread.stops?.count ?? 0)")
            } catch let error as APIError {
                print("❌ Станции маршрута: \(error.localizedDescription)")
            } catch {
                print("❌ Станции маршрута: Системная ошибка - \(error.localizedDescription)")
            }
        }
    }
}
