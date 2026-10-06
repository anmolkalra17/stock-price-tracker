//
//  RegionalFormatter.swift
//  Stock Price Tracker
//
//  Created by Anmol Kalra on 05/10/26.
//

import Foundation

struct RegionalFormatter {
    private static let formatters = NSCache<NSString, NumberFormatter>()
    
    private static func fractionDigits(for currencyCode: String) -> Int {
        currencyCode == "JPY" ? 0 : 2
    }
    
    private static func formatter(for currencyCode: String) -> NumberFormatter {
        if let cached = formatters.object(forKey: currencyCode as NSString) {
            return cached
        }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        formatter.maximumFractionDigits = fractionDigits(for: currencyCode)
        formatter.minimumFractionDigits = fractionDigits(for: currencyCode)
        formatters.setObject(formatter, forKey: currencyCode as NSString)
        return formatter
    }
    
    static func formatPrice(_ price: Double, currencyCode: String = "USD") -> String {
        formatter(for: currencyCode).string(from: NSNumber(value: price)) ?? "\(currencyCode) \(price)"
    }
    
    static func formatChange(_ change: Double, currencyCode: String = "USD") -> String {
        String(format: "%+.\(fractionDigits(for: currencyCode))f", change)
    }
}
