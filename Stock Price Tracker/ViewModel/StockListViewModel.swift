//
//  StockListViewModel.swift
//  Stock Price Tracker
//
//  Created by Anmol Kalra on 05/10/26.
//

import Foundation
import Observation

@Observable
@MainActor
final class StockListViewModel {
    var selectedSortOption: SortOption = .price
    private let repository: StockRepositoryProtocol
    
    var selectedRegion: AppRegion {
        get { repository.selectedRegion }
    }
    
    var connectionError: String? {
        get { repository.connectionError }
        set { repository.connectionError = newValue }
    }
    
    var fxRate: Double {
        repository.selectedRegion.fxRate
    }
    
    var currencyCode: String {
        repository.selectedRegion.currencyCode
    }
    
    var connectionState: ConnectionState {
        repository.connectionState
    }
    
    var sortedStocks: [Stock] {
        let stocks = repository.stocks
        switch selectedSortOption {
        case .price:
            return stocks.sorted { $0.currentPrice > $1.currentPrice }
        case .priceChange:
            return stocks.sorted { abs($0.priceChange) > abs($1.priceChange) }
        }
    }
    
    init(repository: StockRepositoryProtocol) {
        self.repository = repository
    }
    
    func toggleFeed() {
        Task {
            if repository.connectionState == .connected {
                repository.stopFeed()
            } else {
                await repository.startFeed()
            }
        }
    }
}
