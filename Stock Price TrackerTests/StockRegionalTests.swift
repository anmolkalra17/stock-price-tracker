//
//  StockRegionalTests.swift
//  Stock Price TrackerTests
//
//  Created by Anmol Kalra on 05/10/26.
//

import XCTest
import Observation
@testable import Stock_Price_Tracker

// MARK: - StockModel & Regional Formatting Tests -

final class StockRegionalTests: XCTestCase {
    
    func testAppRegionFXRatesAndCurrencies() {
        XCTAssertEqual(AppRegion.usEast.currencyCode, "USD")
        XCTAssertEqual(AppRegion.usEast.fxRate, 1.0)
        
        XCTAssertEqual(AppRegion.euCentral.currencyCode, "EUR")
        XCTAssertEqual(AppRegion.euCentral.fxRate, 0.92)
        
        XCTAssertEqual(AppRegion.apJapan.currencyCode, "JPY")
        XCTAssertEqual(AppRegion.apJapan.fxRate, 150.0)
        
        XCTAssertEqual(AppRegion.apIndia.currencyCode, "INR")
        XCTAssertEqual(AppRegion.apIndia.fxRate, 96.3)
    }
    
    func testRegionalFormatterCurrencyFormatting() {
        let priceUSD = RegionalFormatter.formatPrice(1000.50, currencyCode: "USD")
        XCTAssertTrue(priceUSD.contains("1,000.50") || priceUSD.contains("1000.50"))
        
        let priceJPY = RegionalFormatter.formatPrice(1000.50, currencyCode: "JPY")
        XCTAssertFalse(priceJPY.contains(".50"))
        
        XCTAssertEqual(RegionalFormatter.formatChange(1.2, currencyCode: "USD"), "+1.20")
        XCTAssertEqual(RegionalFormatter.formatChange(-150, currencyCode: "JPY"), "-150")
    }
    
    func testMarketHoursStatusForWeekendAndWeekdaySessions() {
        let saturday = date(2026, 10, 3, 11, 0, in: "America/New_York")
        XCTAssertEqual(MarketHoursManager.status(for: .usEast, date: saturday), .closed)
        
        XCTAssertEqual(MarketHoursManager.status(for: .usEast, date: date(2026, 10, 5, 5, 0, in: "America/New_York")), .preMarket)
        XCTAssertEqual(MarketHoursManager.status(for: .usEast, date: date(2026, 10, 5, 9, 29, in: "America/New_York")), .preMarket)
        XCTAssertEqual(MarketHoursManager.status(for: .usEast, date: date(2026, 10, 5, 9, 30, in: "America/New_York")), .open)
        XCTAssertEqual(MarketHoursManager.status(for: .usEast, date: date(2026, 10, 5, 15, 59, in: "America/New_York")), .open)
        XCTAssertEqual(MarketHoursManager.status(for: .usEast, date: date(2026, 10, 5, 16, 0, in: "America/New_York")), .afterHours)
        XCTAssertEqual(MarketHoursManager.status(for: .usEast, date: date(2026, 10, 5, 11, 0, in: "America/New_York")), .open)
        XCTAssertEqual(MarketHoursManager.status(for: .usEast, date: date(2026, 10, 5, 17, 0, in: "America/New_York")), .afterHours)
        XCTAssertEqual(MarketHoursManager.status(for: .usEast, date: date(2026, 10, 5, 22, 0, in: "America/New_York")), .closed)
    }
    
    private func date(_ year: Int, _ month: Int, _ day: Int, _ hour: Int, _ minute: Int, in timeZoneID: String) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: timeZoneID)!
        return calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute))!
    }
}
