//
//  XCTestCase+WaitUntil.swift
//  Stock Price TrackerTests
//

import XCTest

extension XCTestCase {
    /// Polls `condition` on the main actor until it is true. Fails the test on timeout.
    @MainActor
    func waitUntil(_ description: String,
                   timeout: TimeInterval = 3.0,
                   file: StaticString = #filePath,
                   line: UInt = #line,
                   _ condition: @MainActor () -> Bool) async {
        let deadline = Date().addingTimeInterval(timeout)
        while !condition() {
            if Date() > deadline {
                XCTFail("Timed out waiting for: \(description)", file: file, line: line)
                return
            }
            try? await Task.sleep(nanoseconds: 5_000_000)
        }
    }
}
