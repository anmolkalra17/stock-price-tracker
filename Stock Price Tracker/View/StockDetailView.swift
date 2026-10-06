//
//  StockDetailView.swift
//  Stock Price Tracker
//
//  Created by Anmol Kalra on 05/10/26.
//

import SwiftUI

struct StockDetailView: View {
    var viewModel: StockDetailViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(viewModel.stock.companyName)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text(viewModel.stock.symbol)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                    }
                    
                    Spacer()
                    
                    PriceBadgeView(
                        price: viewModel.stock.currentPrice,
                        rawPrice: viewModel.rawStock.currentPrice,
                        change: viewModel.stock.priceChange,
                        currencyCode: viewModel.currencyCode
                    )
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(LanguageHelper.about)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(viewModel.stock.symbolDescription)
                        .font(.body)
                        .foregroundColor(.primary)
                        .lineSpacing(4)
                }
                .padding(.horizontal, 4)
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle(viewModel.stock.symbol)
        .navigationBarTitleDisplayMode(.inline)
    }
}
