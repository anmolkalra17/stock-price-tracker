//
//  AppRegion.swift
//  Stock Price Tracker
//
//  Created by Anmol Kalra on 05/10/26.
//

import Foundation

enum AppRegion: String, CaseIterable, Identifiable {
    case usEast = "United States (NYSE)"
    case euCentral = "Germany (Frankfurt - XETRA)"
    case apJapan = "Japan (Tokyo - TSE)"
    case apIndia = "India (Mumbai - NSE)"
    case meUAE = "UAE (Dubai - DFM)"
    case apChina = "China (Shanghai - SSE)"
    case ukLondon = "United Kingdom (London - LSE)"
    
    var id: String { rawValue }
    
    var currencyCode: String {
        switch self {
        case .usEast: return "USD"
        case .euCentral: return "EUR"
        case .apJapan: return "JPY"
        case .apIndia: return "INR"
        case .meUAE: return "AED"
        case .apChina: return "CNY"
        case .ukLondon: return "GBP"
        }
    }
    
    // FX multiplier relative to 1.0 USD base
    var fxRate: Double {
        switch self {
        case .usEast: return 1.0
        case .euCentral: return 0.92
        case .apJapan: return 150.0
        case .apIndia: return 96.3
        case .meUAE: return 3.67
        case .apChina: return 6.70
        case .ukLondon: return 0.78
        }
    }
    
    var timeZoneIdentifier: String {
        switch self {
        case .usEast: return "America/New_York"
        case .euCentral: return "Europe/Berlin"
        case .apJapan: return "Asia/Tokyo"
        case .apIndia: return "Asia/Kolkata"
        case .meUAE: return "Asia/Dubai"
        case .apChina: return "Asia/Shanghai"
        case .ukLondon: return "Europe/London"
        }
    }
    
    init?(languageCode: String?) {
        guard let code = languageCode?.lowercased() else { return nil }
        
        switch code {
        case "en": self = .usEast
        case "de": self = .euCentral
        case "ja": self = .apJapan
        case "hi", "en-IN": self = .apIndia
        case "ar": self = .meUAE
        case "zh": self = .apChina
        default:   return nil
        }
    }
}

// MARK: - Market Status -

enum MarketStatus: String {
    case open = "Market Open"
    case closed = "Market Closed"
    case preMarket = "Pre-Market"
    case afterHours = "After-Hours"
}

// MARK: - Market Hours Manager -

struct MarketHoursManager {
    public static func status(for region: AppRegion, date: Date = Date()) -> String {
        var calendar = Calendar(identifier: .gregorian)
        
        var status: MarketStatus
        
        guard let timeZone = TimeZone(identifier: region.timeZoneIdentifier) else {
            status = .closed
            return LanguageHelper.marketClosed
        }
        calendar.timeZone = timeZone
        
        let weekday = calendar.component(.weekday, from: date)
        if weekday == 1 || weekday == 7 { // Weekend
            status = .closed
            return LanguageHelper.marketClosed
        }
        
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let totalMinutes = hour * 60 + minute
        
        switch region {
        case .usEast:
            status = evaluateHours(minutes: totalMinutes, open: 570, close: 960, pre: 240, post: 1200)
        case .euCentral:
            status = evaluateHours(minutes: totalMinutes, open: 540, close: 1050, pre: 480, post: 1200)
        case .apJapan:
            status = evaluateHours(minutes: totalMinutes, open: 540, close: 930, pre: 480, post: 1080)
        case .apIndia:
            status = evaluateHours(minutes: totalMinutes, open: 555, close: 930, pre: 540, post: 960)
        case .meUAE:
            status = evaluateHours(minutes: totalMinutes, open: 600, close: 900, pre: 570, post: 930)
        case .apChina:
            status = evaluateHours(minutes: totalMinutes, open: 570, close: 900, pre: 540, post: 930)
        case .ukLondon:
            status = evaluateHours(minutes: totalMinutes, open: 480, close: 990, pre: 420, post: 1050)
        }
        
        switch status {
        case .open:
            return LanguageHelper.marketOpen
        case .closed:
            return LanguageHelper.marketClosed
        case .preMarket:
            return LanguageHelper.marketPre
        case .afterHours:
            return LanguageHelper.marketAfter
        }
    }
    
    private static func evaluateHours(minutes: Int, open: Int, close: Int, pre: Int, post: Int) -> MarketStatus {
        switch minutes {
        case pre..<open: return .preMarket
        case open..<close: return .open
        case close..<post: return .afterHours
        default: return .closed
        }
    }
}
