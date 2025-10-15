//
//  NetworkChecker.swift
//  TravelSchedule
//
//  Created by Наталья Черномырдина on 15.10.2025.
//

import Foundation
import Network

enum ConnectivityState { case online, offline }

final class NetworkChecker: ObservableObject {
    @Published private(set) var state: ConnectivityState = .online

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "net.checker.queue")

    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.state = (path.status == .satisfied) ? .online : .offline
            }
        }
        monitor.start(queue: queue)
    }

    deinit { monitor.cancel() }
}
