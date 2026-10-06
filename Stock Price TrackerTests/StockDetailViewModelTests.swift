//
//  StockDetailViewModelTests.swift
//  Stock Price TrackerTests
//
//  Created by Anmol Kalra on 05/10/26.
//

import Foundation
import XCTest
@testable import Stock_Price_Tracker

@MainActor
final class StockDetailViewModelTests: XCTestCase {
    private var repository: MockStockRepository!
    
    override func setUp() async throws {
        try await super.setUp()
        repository = MockStockRepository()
    }
    
    override func tearDown() {
        repository = nil
        super.tearDown()
    }
    
    func testDetailViewModelConvertsPriceBasedOnActiveRegion() {
        repository.selectedRegion = .usEast
        let viewModel = StockDetailViewModel(symbol: "AAPL", repository: repository)
        
        let usdPrice = viewModel.stock.currentPrice
        XCTAssertEqual(usdPrice, 100.0)
        
        repository.selectedRegion = .apJapan
        let jpyPrice = viewModel.stock.currentPrice
        
        XCTAssertEqual(jpyPrice, usdPrice * 150.0, accuracy: 0.01)
        XCTAssertEqual(viewModel.currencyCode, "JPY")
    }
    
    func testDetailViewModelFallbackForUnknownSymbol() {
        let viewModel = StockDetailViewModel(symbol: "NONEXISTENT", repository: repository)
        XCTAssertEqual(viewModel.stock.symbol, "NONEXISTENT")
        XCTAssertEqual(viewModel.stock.currentPrice, 0.0)
        XCTAssertEqual(viewModel.stock.symbolDescription, "No details available.")
    }
}
