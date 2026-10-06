//
//  ConnectionState.swift
//  Stock Price Tracker
//
//  Created by Anmol Kalra on 05/10/26.
//

import Foundation

enum ConnectionState: String {
    case connected = "Connected"
    case disconnected = "Disconnected"
    case connecting = "Connecting..."
}

enum SortOption: String, CaseIterable, Identifiable {
    case price = "Price"
    case priceChange = "Price Change"
    
    var id: String { rawValue }
    
    var localized: String {
        switch self {
        case .price:
            return LanguageHelper.sortPrice
        case .priceChange:
            return LanguageHelper.sortPriceChange
        }
    }
}
