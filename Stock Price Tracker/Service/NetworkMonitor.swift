//
//  NetworkMonitor.swift
//  Stock Price Tracker
//
//  Created by Anmol Kalra on 07/10/26.
//

import Foundation
import Network

protocol NetworkMonitoring: Sendable {
    var isConnected: Bool { get }
    var updates: AsyncStream<Bool> { get }
}

final class NetworkMonitor: NetworkMonitoring {
    static let instance = NetworkMonitor()
    
    let updates: AsyncStream<Bool>
    private let monitor = NWPathMonitor()
    
    var isConnected: Bool {
        monitor.currentPath.status == .satisfied
    }
    
    private init() {
        let (stream, continuation) = AsyncStream.makeStream(of: Bool.self, bufferingPolicy: .bufferingNewest(1))
        updates = stream
        
        monitor.pathUpdateHandler = { path in
            continuation.yield(path.status == .satisfied)
        }
        
        monitor.start(queue: DispatchQueue(label: "NetworkMonitoringQueue"))
    }
}
