//
//  PriceUpdateMessageTests.swift
//  Stock Price TrackerTests
//
//  Created by Anmol Kalra on 05/10/26.
//

import Foundation
import XCTest
@testable import Stock_Price_Tracker

final class PriceUpdateMessageJSONTests: XCTestCase {
    
    func testPriceUpdateMessageDecoding() throws {
        let json = """
        {
            "symbol": "NVDA",
            "price": 895.50,
            "timestamp": 1000.5
        }
        """.data(using: .utf8)!
        
        let update = try JSONDecoder().decode(PriceUpdateMessage.self, from: json)
        
        XCTAssertEqual(update.symbol, "NVDA")
        XCTAssertEqual(update.price, 895.50)
        XCTAssertEqual(update.timestamp.timeIntervalSinceReferenceDate, 1000.5, accuracy: 0.001)
    }
    
    func testPriceUpdateMessageEncoding() throws {
        let update = PriceUpdateMessage(symbol: "AAPL", price: 175.25, timestamp: Date(timeIntervalSince1970: 1000))
        let encoder = JSONEncoder()
        
        let data = try encoder.encode(update)
        let jsonString = String(data: data, encoding: .utf8)!
        
        XCTAssertTrue(jsonString.contains("AAPL"))
        XCTAssertTrue(jsonString.contains("175.25"))
    }
}
