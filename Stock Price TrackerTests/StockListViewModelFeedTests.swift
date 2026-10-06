//
//  StockListViewModelFeedTests.swift
//  Stock Price TrackerTests
//
//  Created by Anmol Kalra on 07/10/26.
//

import XCTest
@testable import Stock_Price_Tracker

@MainActor
final class StockListViewModelFeedTests: XCTestCase {
    private var repository: MockStockRepository!
    private var viewModel: StockListViewModel!
    
    override func setUp() async throws {
        try await super.setUp()
        repository = MockStockRepository()
        viewModel = StockListViewModel(repository: repository)
    }
    
    override func tearDown() async throws {
        viewModel = nil
        repository = nil
        try await super.tearDown()
    }
    
    func testToggleFeed_whenDisconnected_startsFeed() async {
        repository.connectionState = .disconnected
        
        viewModel.toggleFeed()
        
        await waitUntil("feed started") { repository.connectionState == .connected }
        XCTAssertEqual(viewModel.connectionState, .connected)
    }
    
    func testToggleFeed_whenConnected_stopsFeed() async {
        repository.connectionState = .connected
        
        viewModel.toggleFeed()
        
        await waitUntil("feed stopped") { repository.connectionState == .disconnected }
        XCTAssertEqual(viewModel.connectionState, .disconnected)
    }
}
