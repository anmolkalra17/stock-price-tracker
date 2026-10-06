//
//  PriceBadgeView.swift
//  Stock Price Tracker
//
//  Created by Anmol Kalra on 05/10/26.
//

import SwiftUI

struct PriceBadgeView: View {
    let price: Double
    let rawPrice: Double
    let change: Double
    var currencyCode: String = "USD"
    
    @State private var flashColor: Color = .clear
    private var isPositive: Bool { change >= 0 }
    
    var body: some View {
        VStack(spacing: 8) {
            Text(RegionalFormatter.formatPrice(price, currencyCode: currencyCode))
                .font(.system(.body))
                .fontWeight(.bold)
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
            
            HStack(spacing: 3) {
                Image(systemName: "triangle.fill")
                    .rotationEffect(isPositive ? .degrees(0) : .degrees(180))
                    .font(.system(size: 8))
                
                Text(RegionalFormatter.formatChange(change, currencyCode: currencyCode))
                    .font(.system(.caption))
                    .fontWeight(.semibold)
                    .lineLimit(1)
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
            .background(isPositive ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
            .foregroundColor(isPositive ? .green : .red)
            .cornerRadius(4)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Price \(RegionalFormatter.formatPrice(price, currencyCode: currencyCode)), change \(RegionalFormatter.formatChange(change, currencyCode: currencyCode))")
        .padding(4)
        .background(flashColor)
        .cornerRadius(6)
        .onChange(of: rawPrice) { oldValue, newValue in
            withAnimation(.easeOut(duration: 0.15)) {
                flashColor = newValue >= oldValue ? Color.green.opacity(0.4) : Color.red.opacity(0.4)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                withAnimation(.easeOut(duration: 0.3)) {
                    flashColor = .clear
                }
            }
        }
    }
}
