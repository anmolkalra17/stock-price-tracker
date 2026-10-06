//
//  FeedIntegrationTests.swift
//  Stock Price TrackerTests
//
//  Created by Anmol Kalra on 07/10/26.
//

import XCTest
@testable import Stock_Price_Tracker

@MainActor
final class FeedIntegrationTests: XCTestCase {
    private var updates: ScriptedUpdates!
    private var repository: StockRepository!
    private var listViewModel: StockListViewModel!
    
    override func setUp() async throws {
        try await super.setUp()
        let connection = MockWebSocketConnection()
        let updates = ScriptedUpdates()
        self.updates = updates
        repository = StockRepository(webSocketFactory: { _ in connection },
                                     priceUpdateProvider: { _ in updates.next() })
        listViewModel = StockListViewModel(repository: repository)
    }
    
    override func tearDown() async throws {
        repository.stopFeed()
        listViewModel = nil
        repository = nil
        updates = nil
        try await super.tearDown()
    }
    
    func testToggleFeedTwice_startsThenStops() async {
        listViewModel.toggleFeed()
        await waitUntil("connected") { listViewModel.connectionState == .connected }
        
        listViewModel.toggleFeed()
        await waitUntil("disconnected") { listViewModel.connectionState == .disconnected }
    }
}
