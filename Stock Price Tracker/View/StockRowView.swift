//
//  StockRowView.swift
//  Stock Price Tracker
//
//  Created by Anmol Kalra on 05/10/26.
//

import SwiftUI

struct StockRowView: View {
    let stock: Stock
    var fxRate: Double = 1.0
    var currencyCode: String = "USD"
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(stock.symbol)
                    .font(.headline)
                Text(stock.companyName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            PriceBadgeView(
                price: stock.currentPrice * fxRate,
                rawPrice: stock.currentPrice,
                change: stock.priceChange * fxRate,
                currencyCode: currencyCode
            )
        }
        .padding(.vertical, 4)
    }
}
