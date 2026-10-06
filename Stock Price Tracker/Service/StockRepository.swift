//
//  StockRepository.swift
//  Stock Price Tracker
//
//  Created by Anmol Kalra on 05/10/26.
//

import Foundation
import Observation

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
final class StockRepository: StockRepositoryProtocol {
    private(set) var stocks: [Stock] = StockRepository.seedData
    private(set) var connectionState: ConnectionState = .disconnected
    var connectionError: String?
    
    private var webSocketTask: WebSocketConnection?
    private let session = URLSession(configuration: .default)
    private var updateTask: Task<Void, Never>?
    private let url = URL(string: "wss://ws.postman-echo.com/raw")!
    
    var selectedRegion: AppRegion {
        let langCode = Locale.autoupdatingCurrent.language.languageCode?.identifier
        return AppRegion(languageCode: langCode) ?? .usEast
    }
    
    private let webSocketFactory: ((URL) -> WebSocketConnection)?
    private let priceUpdateProvider: (([Stock]) -> PriceUpdateMessage?)?
    
    init(webSocketFactory: ((URL) -> WebSocketConnection)? = nil,
         priceUpdateProvider: (([Stock]) -> PriceUpdateMessage?)? = nil) {
        self.webSocketFactory = webSocketFactory
        self.priceUpdateProvider = priceUpdateProvider
    }
    
    func startFeed() async {
        guard connectionState == .disconnected else { return }
        connectionError = nil
        connectionState = .connecting
        
        let task: WebSocketConnection = webSocketFactory?(url) ?? session.webSocketTask(with: url)
        webSocketTask = task
        task.resume()
        connectionState = .connected
        
        listenWebSocket(on: task)
        startSimulatingUpdates()
    }
    
    func stopFeed() {
        updateTask?.cancel()
        updateTask = nil
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        connectionState = .disconnected
    }
    
    func stock(for symbol: String) -> Stock? {
        stocks.first { $0.symbol == symbol }
    }
    
    // MARK: - Private Methods -
    
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
