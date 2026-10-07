//
//  StockRepository.swift
//  Stock Price Tracker
//
//  Created by Anmol Kalra on 05/10/26.
//

import Foundation
import Observation
import Network

@MainActor
protocol StockRepositoryProtocol: AnyObject {
    var stocks: [Stock] { get }
    var connectionState: ConnectionState { get }
    var selectedRegion: AppRegion { get }
    var connectionError: String? { get set }
    
    func startFeed() async
    func stopFeed()
    func stock(for symbol: String) -> Stock?
}

@Observable
@MainActor
final class StockRepository: NSObject, StockRepositoryProtocol {
    private(set) var stocks: [Stock] = StockRepository.seedData
    private(set) var connectionState: ConnectionState = .disconnected
    var connectionError: String?
    
    private var webSocketTask: WebSocketConnection?
    private var session: URLSession?
    private var updateTask: Task<Void, Never>?
    private var networkTask: Task<Void, Never>?
    private let url = URL(string: "wss://ws.postman-echo.com/raw")!
    
    var selectedRegion: AppRegion {
        let langCode = Locale.autoupdatingCurrent.language.languageCode?.identifier
        return AppRegion(languageCode: langCode) ?? .usEast
    }
    
    private let webSocketFactory: ((URL) -> WebSocketConnection)?
    private let priceUpdateProvider: (([Stock]) -> PriceUpdateMessage?)?
    
    private let networkMonitor: NetworkMonitoring?
    
    init(webSocketFactory: ((URL) -> WebSocketConnection)? = nil,
         priceUpdateProvider: (([Stock]) -> PriceUpdateMessage?)? = nil,
         networkMonitor: NetworkMonitor? = nil) {
        self.webSocketFactory = webSocketFactory
        self.priceUpdateProvider = priceUpdateProvider
        self.networkMonitor = networkMonitor
        
        super.init()
        observeNetwork()
    }
    
    func startFeed() async {
        guard connectionState == .disconnected else { return }
        
        if let networkMonitor, !networkMonitor.isConnected {
            connectionError = "No internet connection"
            return
        }
        
        connectionError = nil
        connectionState = .connecting
        
        let task: WebSocketConnection
        
        if let webSocketFactory {
            task = webSocketFactory(url)
        } else {
            let newSession = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
            session = newSession
            task = newSession.webSocketTask(with: url)
        }
        
        webSocketTask = task
        task.resume()
        
        listenWebSocket(on: task)
        
        if webSocketFactory != nil {
            connectionDidOpen(on: task)
        }
    }
    
    func stopFeed() {
        updateTask?.cancel()
        updateTask = nil
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        
        session?.finishTasksAndInvalidate()
        session = nil
        
        connectionState = .disconnected
    }
    
    func stock(for symbol: String) -> Stock? {
        stocks.first { $0.symbol == symbol }
    }
    
    // MARK: - Private Methods -
    
    private func observeNetwork() {
        guard let networkMonitor else { return }
        networkTask = Task { [weak self] in
            for await isOnline in networkMonitor.updates {
                guard let self else { return }
                self.handleNetworkChange(isOnline: isOnline)
            }
        }
    }
    
    private func handleNetworkChange(isOnline: Bool) {
        guard !isOnline, connectionState != .disconnected else { return }
        stopFeed()
        connectionError = "Network connection lost."
    }
    
    private func connectionDidOpen(on task: WebSocketConnection) {
        guard webSocketTask === task, connectionState == .connecting else { return }
        connectionState = .connected
        startSimulatingUpdates()
    }
    
    private func connectionDidClose(on task: WebSocketConnection) {
        guard webSocketTask === task else { return }
        stopFeed()
    }
    
    private func listenWebSocket(on task: WebSocketConnection) {
        Task { [weak self] in
            do {
                let message = try await task.receive()
                guard let self, self.webSocketTask === task else { return }
                
                switch message {
                case .string(let text):
                    self.handleEchoMessage(text)
                    debugPrint("Received data: \(text)")
                case .data(let data):
                    if let text = String(data: data, encoding: .utf8) {
                        self.handleEchoMessage(text)
                    }
                @unknown default:
                    break
                }
                
                if self.connectionState == .connected {
                    self.listenWebSocket(on: task)
                }
            } catch {
                self?.handleSocketFailure(error, on: task)
            }
        }
    }
    
    private func handleSocketFailure(_ error: Error, on task: WebSocketConnection) {
        guard webSocketTask === task else { return }
        stopFeed()
        connectionError = error.localizedDescription
    }
    
    private func handleEchoMessage(_ text: String) {
        guard let data = text.data(using: .utf8),
              let update = try? JSONDecoder().decode(PriceUpdateMessage.self, from: data) else { return }
        
        if let index = stocks.firstIndex(where: { $0.symbol == update.symbol }) {
            let oldPrice = stocks[index].currentPrice
            stocks[index].priceChange = update.price - oldPrice
            stocks[index].currentPrice = update.price
        }
    }
    
    private func makePriceUpdate() -> PriceUpdateMessage? {
        if let priceUpdateProvider { return priceUpdateProvider(stocks) }
        guard let randomStock = stocks.randomElement() else { return nil }
        
        let priceDelta = Double.random(in: -3.0...3.0)
        let newPrice = max(1.0, randomStock.currentPrice + priceDelta)
        
        return PriceUpdateMessage(symbol: randomStock.symbol, price: newPrice, timestamp: Date())
    }
    
    private func startSimulatingUpdates() {
        updateTask?.cancel()
        updateTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 500_000_000) //  0.5s
                
                guard let self, !Task.isCancelled,
                      self.connectionState == .connected,
                      let update = self.makePriceUpdate() else { break }
                
                if let encoder = try? JSONEncoder().encode(update),
                   let jsonString = String(data: encoder, encoding: .utf8) {
                    guard let socket = self.webSocketTask else { break }
                    do {
                        try await socket.send(.string(jsonString))
                        debugPrint("Sent data: \(jsonString)")
                    } catch {
                        self.handleSocketFailure(error, on: socket)
                        break
                    }
                }
            }
        }
    }
}

extension StockRepository: URLSessionWebSocketDelegate {
    nonisolated func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        Task { @MainActor in
            self.connectionDidOpen(on: webSocketTask)
        }
    }
    
    nonisolated func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        Task { @MainActor in
            self.connectionDidClose(on: webSocketTask)
        }
    }
}
