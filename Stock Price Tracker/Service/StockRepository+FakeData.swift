//
//  StockRepository+FakeData.swift
//  Stock Price Tracker
//
//  Created by Anmol Kalra on 05/10/26.
//

import Foundation

extension StockRepository {
    static let seedData: [Stock] = [
        Stock(id: "AAPL", symbol: "AAPL", companyName: "Apple Inc.", currentPrice: 175.50, priceChange: 1.20, symbolDescription: LanguageHelper.description_AAPL),
        Stock(id: "NVDA", symbol: "NVDA", companyName: "NVIDIA Corporation", currentPrice: 880.00, priceChange: -12.40, symbolDescription: LanguageHelper.description_NVDA),
        Stock(id: "GOOG", symbol: "GOOG", companyName: "Alphabet Inc.", currentPrice: 140.20, priceChange: 0.85, symbolDescription: LanguageHelper.description_GOOG),
        Stock(id: "AMZN", symbol: "AMZN", companyName: "Amazon.com Inc.", currentPrice: 178.35, priceChange: -2.10, symbolDescription: LanguageHelper.description_AMZN),
        Stock(id: "MSFT", symbol: "MSFT", companyName: "Microsoft Corp.", currentPrice: 415.10, priceChange: 3.45, symbolDescription: LanguageHelper.description_MSFT),
        Stock(id: "TSLA", symbol: "TSLA", companyName: "Tesla, Inc.", currentPrice: 175.22, priceChange: -4.50, symbolDescription: LanguageHelper.description_TSLA),
        Stock(id: "META", symbol: "META", companyName: "Meta Platforms, Inc.", currentPrice: 485.60, priceChange: 6.20, symbolDescription: LanguageHelper.description_META),
        Stock(id: "NFLX", symbol: "NFLX", companyName: "Netflix, Inc.", currentPrice: 610.30, priceChange: 8.90, symbolDescription: LanguageHelper.description_NFLX),
        Stock(id: "AMD", symbol: "AMD", companyName: "Advanced Micro Devices", currentPrice: 180.40, priceChange: -1.80, symbolDescription: LanguageHelper.description_AMD),
        Stock(id: "INTC", symbol: "INTC", companyName: "Intel Corporation", currentPrice: 42.10, priceChange: 0.15, symbolDescription: LanguageHelper.description_INTC),
        Stock(id: "CRM", symbol: "CRM", companyName: "Salesforce, Inc.", currentPrice: 300.25, priceChange: 2.10, symbolDescription: LanguageHelper.description_CRM),
        Stock(id: "PYPL", symbol: "PYPL", companyName: "PayPal Holdings", currentPrice: 64.80, priceChange: -0.90, symbolDescription: LanguageHelper.description_PYPL),
        Stock(id: "UBER", symbol: "UBER", companyName: "Uber Technologies", currentPrice: 77.40, priceChange: 1.15, symbolDescription: LanguageHelper.description_UBER),
        Stock(id: "ABNB", symbol: "ABNB", companyName: "Airbnb, Inc.", currentPrice: 162.00, priceChange: -2.30, symbolDescription: LanguageHelper.description_ABNB),
        Stock(id: "ORCL", symbol: "ORCL", companyName: "Oracle Corp.", currentPrice: 125.70, priceChange: 0.40, symbolDescription: LanguageHelper.description_ORCL),
        Stock(id: "CSCO", symbol: "CSCO", companyName: "Cisco Systems", currentPrice: 49.30, priceChange: -0.10, symbolDescription: LanguageHelper.description_CSCO),
        Stock(id: "ADBE", symbol: "ADBE", companyName: "Adobe Inc.", currentPrice: 505.00, priceChange: 4.80, symbolDescription: LanguageHelper.description_ADBE),
        Stock(id: "DIS", symbol: "DIS", companyName: "Walt Disney Co.", currentPrice: 112.50, priceChange: 1.05, symbolDescription: LanguageHelper.description_DIS),
        Stock(id: "NKE", symbol: "NKE", companyName: "Nike, Inc.", currentPrice: 98.60, priceChange: -0.75, symbolDescription: LanguageHelper.description_NKE),
        Stock(id: "SBUX", symbol: "SBUX", companyName: "Starbucks Corp.", currentPrice: 91.20, priceChange: -0.40, symbolDescription: LanguageHelper.description_SBUX),
        Stock(id: "IBM", symbol: "IBM", companyName: "International Business Machines", currentPrice: 190.80, priceChange: 2.30, symbolDescription: LanguageHelper.description_IBM),
        Stock(id: "QCOM", symbol: "QCOM", companyName: "QUALCOMM Inc.", currentPrice: 168.30, priceChange: 3.10, symbolDescription: LanguageHelper.description_QCOM),
        Stock(id: "TXN", symbol: "TXN", companyName: "Texas Instruments", currentPrice: 172.90, priceChange: -0.80, symbolDescription: LanguageHelper.description_TXN),
        Stock(id: "BAC", symbol: "BAC", companyName: "Bank of America", currentPrice: 37.10, priceChange: 0.25, symbolDescription: LanguageHelper.description_BAC),
        Stock(id: "JPM", symbol: "JPM", companyName: "JPMorgan Chase & Co.", currentPrice: 198.40, priceChange: 1.80, symbolDescription: LanguageHelper.description_JPM)
    ]
}
