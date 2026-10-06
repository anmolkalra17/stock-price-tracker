//
//  StockRepository+FakeData.swift
//  Stock Price Tracker
//
//  Created by Anmol Kalra on 05/10/26.
//

import Foundation

extension StockRepository {
    static let seedData: [Stock] = [
        Stock(id: "AAPL", symbol: "AAPL", companyName: "Apple Inc.", currentPrice: 175.50, priceChange: 1.20, symbolDescription: "Apple Inc. designs, manufactures, and markets smartphones, personal computers, tablets, wearables, and accessories."),
        Stock(id: "NVDA", symbol: "NVDA", companyName: "NVIDIA Corporation", currentPrice: 880.00, priceChange: -12.40, symbolDescription: "NVIDIA Corporation designs graphics processing units for gaming and professional markets, as well as system on a chip units for mobile computing."),
        Stock(id: "GOOG", symbol: "GOOG", companyName: "Alphabet Inc.", currentPrice: 140.20, priceChange: 0.85, symbolDescription: "Alphabet Inc. offers web-based search, cloud computing, streaming entertainment, and hardware products."),
        Stock(id: "AMZN", symbol: "AMZN", companyName: "Amazon.com Inc.", currentPrice: 178.35, priceChange: -2.10, symbolDescription: "Amazon.com, Inc. focuses on e-commerce, cloud computing, online advertising, digital streaming, and AI."),
        Stock(id: "MSFT", symbol: "MSFT", companyName: "Microsoft Corp.", currentPrice: 415.10, priceChange: 3.45, symbolDescription: "Microsoft develops and supports software, services, devices and solutions."),
        Stock(id: "TSLA", symbol: "TSLA", companyName: "Tesla, Inc.", currentPrice: 175.22, priceChange: -4.50, symbolDescription: "Tesla, Inc. designs and manufactures electric vehicles, solar panels, and energy storage devices."),
        Stock(id: "META", symbol: "META", companyName: "Meta Platforms, Inc.", currentPrice: 485.60, priceChange: 6.20, symbolDescription: "Meta Platforms develops products that enable people to connect and share through mobile devices and personal computers."),
        Stock(id: "NFLX", symbol: "NFLX", companyName: "Netflix, Inc.", currentPrice: 610.30, priceChange: 8.90, symbolDescription: "Netflix, Inc. provides subscription streaming entertainment service."),
        Stock(id: "AMD", symbol: "AMD", companyName: "Advanced Micro Devices", currentPrice: 180.40, priceChange: -1.80, symbolDescription: "AMD designs semiconductor devices used in computer processing."),
        Stock(id: "INTC", symbol: "INTC", companyName: "Intel Corporation", currentPrice: 42.10, priceChange: 0.15, symbolDescription: "Intel Corporation designs and manufactures microprocessors and chipset components."),
        Stock(id: "CRM", symbol: "CRM", companyName: "Salesforce, Inc.", currentPrice: 300.25, priceChange: 2.10, symbolDescription: "Salesforce provides enterprise cloud computing solutions."),
        Stock(id: "PYPL", symbol: "PYPL", companyName: "PayPal Holdings", currentPrice: 64.80, priceChange: -0.90, symbolDescription: "PayPal operates an online payments system operating worldwide."),
        Stock(id: "UBER", symbol: "UBER", companyName: "Uber Technologies", currentPrice: 77.40, priceChange: 1.15, symbolDescription: "Uber offers ride-hailing, food delivery, and freight transportation."),
        Stock(id: "ABNB", symbol: "ABNB", companyName: "Airbnb, Inc.", currentPrice: 162.00, priceChange: -2.30, symbolDescription: "Airbnb operates an online marketplace for lodging and tourism activities."),
        Stock(id: "ORCL", symbol: "ORCL", companyName: "Oracle Corp.", currentPrice: 125.70, priceChange: 0.40, symbolDescription: "Oracle provides database software, cloud systems, and enterprise software."),
        Stock(id: "CSCO", symbol: "CSCO", companyName: "Cisco Systems", currentPrice: 49.30, priceChange: -0.10, symbolDescription: "Cisco develops and sells networking hardware and software products."),
        Stock(id: "ADBE", symbol: "ADBE", companyName: "Adobe Inc.", currentPrice: 505.00, priceChange: 4.80, symbolDescription: "Adobe offers digital media and marketing software products."),
        Stock(id: "DIS", symbol: "DIS", companyName: "Walt Disney Co.", currentPrice: 112.50, priceChange: 1.05, symbolDescription: "The Walt Disney Company is a diversified worldwide entertainment company."),
        Stock(id: "NKE", symbol: "NKE", companyName: "Nike, Inc.", currentPrice: 98.60, priceChange: -0.75, symbolDescription: "Nike designs, markets, and sells athletic footwear, apparel, and equipment."),
        Stock(id: "SBUX", symbol: "SBUX", companyName: "Starbucks Corp.", currentPrice: 91.20, priceChange: -0.40, symbolDescription: "Starbucks is the premier roaster and retailer of specialty coffee worldwide."),
        Stock(id: "IBM", symbol: "IBM", companyName: "International Business Machines", currentPrice: 190.80, priceChange: 2.30, symbolDescription: "IBM offers cloud platform and cognitive solutions."),
        Stock(id: "QCOM", symbol: "QCOM", companyName: "QUALCOMM Inc.", currentPrice: 168.30, priceChange: 3.10, symbolDescription: "Qualcomm designs and markets wireless telecommunications products."),
        Stock(id: "TXN", symbol: "TXN", companyName: "Texas Instruments", currentPrice: 172.90, priceChange: -0.80, symbolDescription: "Texas Instruments designs and manufactures semiconductors."),
        Stock(id: "BAC", symbol: "BAC", companyName: "Bank of America", currentPrice: 37.10, priceChange: 0.25, symbolDescription: "Bank of America provides banking and financial services."),
        Stock(id: "JPM", symbol: "JPM", companyName: "JPMorgan Chase & Co.", currentPrice: 198.40, priceChange: 1.80, symbolDescription: "JPMorgan Chase is a financial services firm and banking institution.")
    ]
}
