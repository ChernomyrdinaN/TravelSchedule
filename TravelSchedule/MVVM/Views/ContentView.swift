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
                    print("❌ Nearest Stations: Invalid URL")
                    return
                }
                let client = Client(serverURL: url, transport: URLSessionTransport())
                let service = NearestStationsService(client: client, apikey: Constants.yandexAPIKey)
                
                _ = try await service.getNearestStations(
                    lat: 59.864177,
                    lng: 30.319163,
                    distance: 50
                )
                
                print("✅ Nearest Stations: Success")
            } catch {
                print("❌ Nearest Stations: Error - \(error.localizedDescription)")
            }
        }
    }
    
    private func testFetchStationsList() {
        Task {
            do {
                guard let url = URL(string: "https://api.rasp.yandex.net") else {
                    print("❌ Stations List: Invalid URL")
                    return
                }
                let client = Client(serverURL: url, transport: URLSessionTransport())
                let service = AllStationsService(client: client, apikey: Constants.yandexAPIKey)
                
                _ = try await service.getStationsList()
                print("✅ All Stations: Success")
            } catch {
                print("❌ All Stations: Error - \(error.localizedDescription)")
            }
        }
    }
    
    private func testFetchCarrierInfo() {
        Task {
            do {
                guard let url = URL(string: "https://api.rasp.yandex.net") else {
                    print("❌ Carrier Info: Invalid URL")
                    return
                }
                let client = Client(serverURL: url, transport: URLSessionTransport())
                let service = CarrierService(client: client, apikey: Constants.yandexAPIKey)
                
                _ = try await service.getCarrierInfo(
                    code: "104",
                    system: nil
                )
                
                print("✅ Carrier Info: Success")
            } catch {
                print("❌ Carrier Info: Error - \(error.localizedDescription)")
            }
        }
    }
    
    private func testFetchCopyrights() {
        Task {
            do {
                guard let url = URL(string: "https://api.rasp.yandex.net") else {
                    print("❌ Copyrights: Invalid URL")
                    return
                }
                let client = Client(serverURL: url, transport: URLSessionTransport())
                let service = CopyrightsService(client: client, apikey: Constants.yandexAPIKey)
                
                _ = try await service.getCopyrights()
                print("✅ Copyrights: Success")
            } catch {
                print("❌ Copyrights: Error - \(error.localizedDescription)")
            }
        }
    }
    
    private func testFetchNearestSettlement() {
        Task {
            do {
                guard let url = URL(string: "https://api.rasp.yandex.net") else {
                    print("❌ Nearest Settlement: Invalid URL")
                    return
                }
                let client = Client(serverURL: url, transport: URLSessionTransport())
                let service = NearestSettlementService(client: client, apikey: Constants.yandexAPIKey)
                
                _ = try await service.getNearestSettlement(
                    lat: 55.755826,
                    lng: 37.617300,
                    distance: 50
                )
                
                print("✅ Nearest Settlement: Success")
            } catch {
                print("❌ Nearest Settlement: Error - \(error.localizedDescription)")
            }
        }
    }
    
    private func testFetchScheduleBetweenStations() {
        Task {
            do {
                guard let url = URL(string: "https://api.rasp.yandex.net") else {
                    print("❌ Schedule Between Stations: Invalid URL")
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
                
                print("✅ Schedule Between Stations: Success")
            } catch {
                print("❌ Schedule Between Stations: Error - \(error.localizedDescription)")
            }
        }
    }
    
    private func testFetchScheduleOnStation() {
        Task {
            do {
                guard let url = URL(string: "https://api.rasp.yandex.net") else {
                    print("❌ Schedule On Station: Invalid URL")
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
                
                print("✅ Schedule On Station: Success")
            } catch {
                print("❌ Schedule On Station: Error - \(error.localizedDescription)")
            }
        }
    }
    
    private func testFetchThreadStations() {
        Task {
            do {
                guard let url = URL(string: "https://api.rasp.yandex.net") else {
                    print("❌ Thread Stations: Invalid URL")
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
                
                print("✅ Thread Stations: Success")
            } catch {
                print("❌ Thread Stations: Error - \(error.localizedDescription)")
            }
        }
    }
}
