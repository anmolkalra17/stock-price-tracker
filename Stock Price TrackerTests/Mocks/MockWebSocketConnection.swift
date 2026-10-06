//
//  MockWebSocketConnection.swift
//  Stock Price TrackerTests
//
//  Created by Anmol Kalra on 07/10/26.
//

import Foundation
@testable import Stock_Price_Tracker

/// In-memory stand-in for URLSessionWebSocketTask. Echoes sent messages by default, like the real server.
final class MockWebSocketConnection: WebSocketConnection, @unchecked Sendable {
    typealias Message = URLSessionWebSocketTask.Message
    
    private struct State {
        var echoes = true
        var sendError: Error?
        var sentTexts: [String] = []
        var resumeCount = 0
        var cancelCount = 0
        var lastCloseCode: URLSessionWebSocketTask.CloseCode?
        var closed = false
        var inbound: [Result<Message, Error>] = []
        var receiveWaiter: CheckedContinuation<Message, Error>?
    }
    
    private let lock = NSLock()
    private var state = State()
    
    private func withState<T>(_ body: (inout State) -> T) -> T {
        lock.withLock { body(&state) }
    }
    
    // MARK: - Test Configuration -
    
    var echoesSentMessages: Bool {
        get { withState { $0.echoes } }
        set { withState { $0.echoes = newValue } }
    }
    
    var sendError: Error? {
        get { withState { $0.sendError } }
        set { withState { $0.sendError = newValue } }
    }
    
    // MARK: - Test Inspection -
    
    var sentTexts: [String] { withState { $0.sentTexts } }
    var resumeCount: Int { withState { $0.resumeCount } }
    var cancelCount: Int { withState { $0.cancelCount } }
    var lastCloseCode: URLSessionWebSocketTask.CloseCode? { withState { $0.lastCloseCode } }
    
    // MARK: - Test Driving -
    
    /// Simulates the server pushing a frame.
    func pushIncoming(_ message: Message) {
        deliver(.success(message))
    }
    
    /// Simulates the socket failing while the app is waiting to receive.
    func pushIncomingFailure(_ error: Error) {
        deliver(.failure(error))
    }
    
    // MARK: - WebSocketConnection -
    
    func resume() {
        withState { state in
            state.resumeCount += 1
            state.closed = false
        }
    }
    
    func send(_ message: Message) async throws {
        let (error, shouldEcho) = withState { state -> (Error?, Bool) in
            if case .string(let text) = message { state.sentTexts.append(text) }
            return (state.sendError, state.echoes)
        }
        if let error { throw error }
        if shouldEcho { deliver(.success(message)) }
    }
    
    func receive() async throws -> Message {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Message, Error>) in
            let immediate = withState { state -> Result<Message, Error>? in
                if !state.inbound.isEmpty { return state.inbound.removeFirst() }
                if state.closed { return .failure(URLError(.cancelled)) }
                state.receiveWaiter = continuation
                return nil
            }
            if let immediate { continuation.resume(with: immediate) }
        }
    }
    
    func cancel(with closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        let waiter = withState { state -> CheckedContinuation<Message, Error>? in
            state.cancelCount += 1
            state.lastCloseCode = closeCode
            state.closed = true
            let pending = state.receiveWaiter
            state.receiveWaiter = nil
            return pending
        }
        waiter?.resume(throwing: URLError(.cancelled))
    }
    
    // MARK: - Private Methods -
    
    private func deliver(_ result: Result<Message, Error>) {
        let waiter = withState { state -> CheckedContinuation<Message, Error>? in
            if let waiter = state.receiveWaiter {
                state.receiveWaiter = nil
                return waiter
            }
            state.inbound.append(result)
            return nil
        }
        waiter?.resume(with: result)
    }
}
