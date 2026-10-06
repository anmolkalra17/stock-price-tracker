//
//  Stock.swift
//  Stock Price Tracker
//
//  Created by Anmol Kalra on 05/10/26.
//

import Foundation

struct Stock: Identifiable, Hashable {
    let id: String
    let symbol: String
    let companyName: String
    var currentPrice: Double
    var priceChange: Double
    let symbolDescription: String
    
    var priceChangePercentage: Double {
        let previousPrice = currentPrice - priceChange
        guard previousPrice > 0 else { return 0.0 }
        return (priceChange / previousPrice) * 100.0
    }
}
