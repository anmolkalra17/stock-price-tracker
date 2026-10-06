//
//  LocalizationTests.swift
//  Stock Price TrackerTests
//
//  Created by Anmol Kalra on 07/10/26.
//

import XCTest
@testable import Stock_Price_Tracker

@MainActor
final class LocalizationTests: XCTestCase {
    private let languages = ["en", "de", "ja", "hi", "ar", "zh-Hans"]
    private let appBundle = Bundle(for: StockRepository.self)
    
    private func table(for language: String, file: StaticString = #filePath, line: UInt = #line) throws -> [String: String] {
        let path = try XCTUnwrap(
            appBundle.path(forResource: "Localizable", ofType: "strings", inDirectory: nil, forLocalization: language),
            "Localizable.strings for '\(language)' is not in the app bundle. Add the .lproj folders to the app target and the project's Localizations list.",
            file: file, line: line
        )
        return try XCTUnwrap(NSDictionary(contentsOfFile: path) as? [String: String],
                             "Could not parse \(path)", file: file, line: line)
    }
    
    /// "%1$@" and "%@" both normalise to "@", so we compare the multiset of specifier types.
    private func specifiers(in string: String) -> [String] {
        let regex = try! NSRegularExpression(pattern: #"%(?:\d+\$)?[@dfsi]"#)
        let range = NSRange(string.startIndex..., in: string)
        return regex.matches(in: string, range: range)
            .compactMap { Range($0.range, in: string).map { String(string[$0].last!) } }
            .sorted()
    }
    
    // MARK: - Consistency -
    
    func testEveryLanguage_hasExactlyTheSameKeysAsEnglish() throws {
        let english = Set(try table(for: "en").keys)
        
        for language in languages where language != "en" {
            let keys = Set(try table(for: language).keys)
            XCTAssertEqual(english.subtracting(keys), [], "\(language) is missing keys")
            XCTAssertEqual(keys.subtracting(english), [], "\(language) has keys not in en")
        }
    }
    
    func testEveryTranslation_isNonEmptyAndKeepsFormatSpecifiers() throws {
        let english = try table(for: "en")
        
        for language in languages {
            let strings = try table(for: language)
            for (key, value) in strings {
                XCTAssertFalse(value.trimmingCharacters(in: .whitespaces).isEmpty, "\(language): '\(key)' is empty")
                XCTAssertEqual(specifiers(in: value), specifiers(in: english[key] ?? ""),
                               "\(language): placeholders differ from en for '\(key)'")
            }
        }
    }
    
    // MARK: - Coverage of Code-Defined Strings -
    
    func testEverySeedSymbol_hasDescriptionKeyMatchingSeedData() throws {
        let english = try table(for: "en")
        
        for stock in StockRepository.seedData {
            XCTAssertEqual(english["stock.\(stock.symbol).description"], stock.symbolDescription,
                           "Seed description for \(stock.symbol) drifted from the en strings file")
        }
    }
    
    func testEveryRegionSortOptionAndConnectionState_hasAKey() throws {
        let english = try table(for: "en")
        
        let expected =
            AppRegion.allCases.map { "region.\(String(describing: $0))" } +
            SortOption.allCases.map { "sort.\(String(describing: $0))" } +
            ["connected", "disconnected", "connecting"].map { "connection.\($0)" } +
            ["open", "closed", "preMarket", "afterHours"].map { "market.\($0)" } +
            ["stocks.title", "feed.start", "feed.stop", "detail.about", "detail.noDetails",
             "error.connectionFailed.title", "common.ok", "price.accessibility", "feed.status.accessibility"]
        
        for key in expected {
            XCTAssertNotNil(english[key], "Missing key '\(key)' in en")
        }
    }
}
