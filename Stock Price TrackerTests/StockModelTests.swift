//
//  StockModelTests.swift
//  Stock Price TrackerTests
//
//  Created by Anmol Kalra on 05/10/26.
//

import XCTest
@testable import Stock_Price_Tracker

final class StockModelTests: XCTestCase {
    
    func testStockPriceChangePercentagePositive() {
        let stock = Stock(
            id: "AAPL",
            symbol: "AAPL",
            companyName: "Apple Inc.",
            currentPrice: 110.0,
            priceChange: 10.0,
            symbolDescription: "Description"
        )
        
        XCTAssertEqual(stock.priceChangePercentage, 10.0, accuracy: 0.001)
    }
    
    func testStockPriceChangePercentageNegative() {
        let stock = Stock(
            id: "TSLA",
            symbol: "TSLA",
            companyName: "Tesla, Inc.",
            currentPrice: 90.0,
            priceChange: -10.0,
            symbolDescription: "Description"
        )
        
        XCTAssertEqual(stock.priceChangePercentage, -10.0, accuracy: 0.001)
    }
    
    func testStockPriceChangePercentageZeroGuard() {
        let stock = Stock(
            id: "NEW",
            symbol: "NEW",
            companyName: "New Co",
            currentPrice: 5.0,
            priceChange: 5.0,
            symbolDescription: "Description"
        )
        
        XCTAssertEqual(stock.priceChangePercentage, 0.0)
    }
}
