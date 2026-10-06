//
//  StockRepositoryTests.swift
//  Stock Price TrackerTests
//
//  Created by Anmol Kalra on 07/10/26.
//

import XCTest
@testable import Stock_Price_Tracker

@MainActor
final class StockRepositoryTests: XCTestCase {
    private var connection: MockWebSocketConnection!
    private var updates: ScriptedUpdates!
    private var sut: StockRepository!
    
    override func setUp() async throws {
        try await super.setUp()
        let connection = MockWebSocketConnection()
        let updates = ScriptedUpdates()
        self.connection = connection
        self.updates = updates
        sut = StockRepository(webSocketFactory: { _ in connection },
                              priceUpdateProvider: { _ in updates.next() })
    }
    
    override func tearDown() async throws {
        sut.stopFeed()
        sut = nil
        connection = nil
        updates = nil
        try await super.tearDown()
    }
    
    private func price(_ symbol: String) -> Double {
        sut.stock(for: symbol)?.currentPrice ?? .nan
    }
    
    // MARK: - Initial State -
    
    func testDefaultRepository_startsDisconnectedWithTwentyFiveUniqueSymbols() {
        let repository = StockRepository()
        
        XCTAssertEqual(repository.connectionState, .disconnected)
        XCTAssertNil(repository.connectionError)
        XCTAssertEqual(repository.stocks.count, 25)
        XCTAssertEqual(Set(repository.stocks.map(\.symbol)).count, 25)
    }
    
    func testStockLookup_returnsMatchingStockOrNil() {
        XCTAssertEqual(sut.stock(for: "AAPL")?.symbol, "AAPL")
        XCTAssertNil(sut.stock(for: "ZZZZ"))
    }
    
    // MARK: - Start / Stop -
    
    func testStartFeed_connectsAndResumesSocket() async {
        await sut.startFeed()
        
        XCTAssertEqual(sut.connectionState, .connected)
        XCTAssertEqual(connection.resumeCount, 1)
    }
    
    func testStartFeed_whenAlreadyConnected_doesNotReconnect() async {
        await sut.startFeed()
        await sut.startFeed()
        
        XCTAssertEqual(connection.resumeCount, 1)
    }
    
    func testStartFeed_clearsPreviousError() async {
        sut.connectionError = "old error"
        
        await sut.startFeed()
        
        XCTAssertNil(sut.connectionError)
    }
    
    func testStopFeed_cancelsSocketWithGoingAwayAndDisconnects() async {
        await sut.startFeed()
        
        sut.stopFeed()
        
        XCTAssertEqual(sut.connectionState, .disconnected)
        XCTAssertEqual(connection.cancelCount, 1)
        XCTAssertEqual(connection.lastCloseCode, .goingAway)
    }
    
    func testStopFeed_beforeStart_isHarmless() {
        sut.stopFeed()
        
        XCTAssertEqual(sut.connectionState, .disconnected)
        XCTAssertEqual(connection.cancelCount, 0)
    }
    
    func testRestartAfterStop_opensANewConnection() async {
        await sut.startFeed()
        sut.stopFeed()
        
        await sut.startFeed()
        
        XCTAssertEqual(sut.connectionState, .connected)
        XCTAssertEqual(connection.resumeCount, 2)
    }
    
    func testStopFeed_whileWaitingToReceive_doesNotPublishAnError() async throws {
        await sut.startFeed()
        
        sut.stopFeed()
        try await Task.sleep(nanoseconds: 50_000_000) // let the cancelled receive finish
        
        XCTAssertNil(sut.connectionError)
    }
    
    // MARK: - Price Updates -
    
    func testEchoedUpdate_updatesPriceAndChange() async throws {
        let original = price("AAPL")
        updates.enqueue(symbol: "AAPL", price: original + 10)
        
        await sut.startFeed()
        await waitUntil("AAPL updated") { sut.stock(for: "AAPL")?.currentPrice == original + 10 }
        
        let aapl = try XCTUnwrap(sut.stock(for: "AAPL"))
        XCTAssertEqual(aapl.priceChange, 10, accuracy: 0.0001)
    }
    
    func testSentPayload_isValidPriceUpdateJSON() async throws {
        updates.enqueue(symbol: "NVDA", price: 900)
        
        await sut.startFeed()
        await waitUntil("message sent") { connection.sentTexts.count == 1 }
        
        let decoded = try JSONDecoder().decode(PriceUpdateMessage.self, from: Data(connection.sentTexts[0].utf8))
        XCTAssertEqual(decoded.symbol, "NVDA")
        XCTAssertEqual(decoded.price, 900, accuracy: 0.0001)
    }
    
    func testSequentialUpdates_changeIsRelativeToPreviousPrice() async {
        updates.enqueue(symbol: "AAPL", price: 180)
        updates.enqueue(symbol: "AAPL", price: 170)
        
        await sut.startFeed()
        await waitUntil("second update applied") { sut.stock(for: "AAPL")?.currentPrice == 170 }
        
        XCTAssertEqual(sut.stock(for: "AAPL")?.priceChange ?? 0, -10, accuracy: 0.0001)
    }
    
    func testIncomingMessages_malformedOrUnknown_areIgnoredAndDataFramesAreHandled() async {
        let aaplBefore = price("AAPL")
        await sut.startFeed()
        
        connection.pushIncoming(.string("not json"))
        connection.pushIncoming(.string(TestFrames.priceUpdate("ZZZZ", 50)))
        connection.pushIncoming(.data(Data(TestFrames.priceUpdate("NVDA", 900).utf8))) // also proves .data frames work
        await waitUntil("NVDA updated from data frame") { price("NVDA") == 900 }
        
        XCTAssertEqual(price("AAPL"), aaplBefore)
        XCTAssertEqual(sut.stocks.count, 25)
        XCTAssertEqual(sut.connectionState, .connected)
    }
    
    func testUpdatesArrivingAfterStop_areNotApplied() async throws {
        let before = price("AAPL")
        await sut.startFeed()
        sut.stopFeed()
        
        connection.pushIncoming(.string(TestFrames.priceUpdate("AAPL", before + 50)))
        try await Task.sleep(nanoseconds: 50_000_000) // negative assertion: short grace period
        
        XCTAssertEqual(price("AAPL"), before)
    }
    
    // MARK: - Failures -
    
    func testReceiveFailure_stopsFeedAndPublishesError() async {
        await sut.startFeed()
        
        connection.pushIncomingFailure(URLError(.networkConnectionLost))
        await waitUntil("feed stopped") { sut.connectionState == .disconnected }
        
        XCTAssertEqual(sut.connectionError, URLError(.networkConnectionLost).localizedDescription)
    }
    
    func testSendFailure_stopsFeedAndPublishesError() async {
        connection.sendError = URLError(.notConnectedToInternet)
        updates.enqueue(symbol: "AAPL", price: 180)
        
        await sut.startFeed()
        await waitUntil("feed stopped") { sut.connectionState == .disconnected }
        
        XCTAssertEqual(sut.connectionError, URLError(.notConnectedToInternet).localizedDescription)
    }
}
