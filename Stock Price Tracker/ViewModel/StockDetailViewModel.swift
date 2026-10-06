//
//  StockDetailViewModel.swift
//  Stock Price Tracker
//
//  Created by Anmol Kalra on 05/10/26.
//

import Foundation
import Observation

@Observable
@MainActor
final class StockDetailViewModel {
    private let symbol: String
    private let repository: StockRepositoryProtocol
    
    var currencyCode: String {
        repository.selectedRegion.currencyCode
    }
    
    var fxRate: Double {
        repository.selectedRegion.fxRate
    }
    
    var rawStock: Stock {
        repository.stock(for: symbol) ?? Stock(
            id: symbol,
            symbol: symbol,
            companyName: symbol,
            currentPrice: 0.0,
            priceChange: 0.0,
            symbolDescription: "No details available."
        )
    }
    
    var stock: Stock {
        var convertedStock = rawStock
        convertedStock.currentPrice *= fxRate
        convertedStock.priceChange *= fxRate
        return convertedStock
    }
    
    init(symbol: String, repository: StockRepositoryProtocol) {
        self.symbol = symbol
        self.repository = repository
    }
}
