//
//  PriceUpdateMessage.swift
//  Stock Price Tracker
//
//  Created by Anmol Kalra on 05/10/26.
//

import Foundation

struct PriceUpdateMessage: Codable {
    let symbol: String
    let price: Double
    let timestamp: Date
}
