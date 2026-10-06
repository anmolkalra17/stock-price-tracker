//
//  StockListViewModelTests.swift
//  Stock Price TrackerTests
//
//  Created by Anmol Kalra on 05/10/26.
//

import Foundation
import XCTest
@testable import Stock_Price_Tracker

@MainActor
final class StockListViewModelTests: XCTestCase {
    private var repository: MockStockRepository!
    private var viewModel: StockListViewModel!
    
    override func setUp() async throws {
        try await super.setUp()
        repository = MockStockRepository()
        viewModel = StockListViewModel(repository: repository)
    }
    
    override func tearDown() {
        repository = nil
        viewModel = nil
        super.tearDown()
    }
    
    func testSortingByPriceAndByAbsolutePriceChangeDescending() {
        viewModel.selectedSortOption = .price
        XCTAssertEqual(viewModel.sortedStocks.map(\.symbol), ["NVDA", "AAPL", "TSLA"])
        
        viewModel.selectedSortOption = .priceChange
        XCTAssertEqual(viewModel.sortedStocks.map(\.symbol), ["NVDA", "TSLA", "AAPL"])
    }
    
    func testConnectionErrorIsExposedAndCanBeDismissed() {
        XCTAssertNil(viewModel.connectionError)
        
        repository.connectionError = "The network connection was lost."
        XCTAssertEqual(viewModel.connectionError, "The network connection was lost.")
        
        viewModel.connectionError = nil
        XCTAssertNil(repository.connectionError)
    }
    
    func testRegionChangeUpdatesCurrencyAndFXRate() {
        XCTAssertEqual(viewModel.selectedRegion, .usEast)
        XCTAssertEqual(viewModel.currencyCode, "USD")
        XCTAssertEqual(viewModel.fxRate, 1.0)
        
        viewModel.selectedRegion = .apJapan
        XCTAssertEqual(viewModel.currencyCode, "JPY")
        XCTAssertEqual(viewModel.fxRate, 150.0)
        
        viewModel.selectedRegion = .ukLondon
        XCTAssertEqual(viewModel.currencyCode, "GBP")
        XCTAssertEqual(viewModel.fxRate, 0.78)
    }
}
