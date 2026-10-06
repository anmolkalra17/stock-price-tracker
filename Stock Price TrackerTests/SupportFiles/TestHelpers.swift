//
//  TestHelpers.swift
//  Stock Price TrackerTests
//

import Foundation
@testable import Stock_Price_Tracker

final class ScriptedUpdates {
    private var queue: [PriceUpdateMessage] = []
    
    func enqueue(symbol: String, price: Double) {
        queue.append(PriceUpdateMessage(symbol: symbol, price: price, timestamp: Date(timeIntervalSince1970: 0)))
    }
    
    func next() -> PriceUpdateMessage? {
        queue.isEmpty ? nil : queue.removeFirst()
    }
}

enum TestFrames {
    /// A text payload as the echo server would return it.
    static func priceUpdate(_ symbol: String, _ price: Double) -> String {
        let message = PriceUpdateMessage(symbol: symbol, price: price, timestamp: Date(timeIntervalSince1970: 0))
        let data = try! JSONEncoder().encode(message)
        return String(decoding: data, as: UTF8.self)
    }
}
