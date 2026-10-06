//
//  MockStockRepository.swift
//  Stock Price TrackerTests
//
//  Created by Anmol Kalra on 05/10/26.
//

import Foundation
@testable import Stock_Price_Tracker

@Observable
@MainActor
final class MockStockRepository: StockRepositoryProtocol {
    var stocks: [Stock] = [
        Stock(id: "AAPL", symbol: "AAPL", companyName: "Apple Inc.", currentPrice: 100.0, priceChange: 1.0, symbolDescription: LanguageHelper.description_AAPL),
        Stock(id: "NVDA", symbol: "NVDA", companyName: "NVIDIA Corporation", currentPrice: 200.0, priceChange: -5.0, symbolDescription: LanguageHelper.description_NVDA),
        Stock(id: "TSLA", symbol: "TSLA", companyName: "Tesla, Inc.", currentPrice: 50.0, priceChange: 3.0, symbolDescription: LanguageHelper.description_TSLA)
    ]
    var connectionState: ConnectionState = .disconnected
    var selectedRegion: AppRegion = .usEast
    var connectionError: String?
    
    func startFeed() async {
        connectionState = .connected
    }
    
    func stopFeed() {
        connectionState = .disconnected
    }
    
    func stock(for symbol: String) -> Stock? {
        stocks.first { $0.symbol == symbol }
    }
}
