//
//  WebSocketConnection.swift
//  Stock Price Tracker
//
//  Created by Anmol Kalra on 07/10/26.
//

import Foundation

// MARK: - WebSocketConnection -

/// The subset of URLSessionWebSocketTask the repository uses, so tests can substitute it.
protocol WebSocketConnection: AnyObject, Sendable {
    func resume()
    func send(_ message: URLSessionWebSocketTask.Message) async throws
    func receive() async throws -> URLSessionWebSocketTask.Message
    func cancel(with closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?)
}

extension URLSessionWebSocketTask: WebSocketConnection {}
