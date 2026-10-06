//
//  StockListView.swift
//  Stock Price Tracker
//
//  Created by Anmol Kalra on 05/10/26.
//

import SwiftUI

struct StockListView: View {
    @State private var viewModel: StockListViewModel
    private let repository: StockRepositoryProtocol
    
    init(repository: StockRepositoryProtocol) {
        self.repository = repository
        _viewModel = State(wrappedValue: StockListViewModel(repository: repository))
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                HStack {
                    TimelineView(.periodic(from: .now, by: 60)) { context in
                        Text(MarketHoursManager.status(for: viewModel.selectedRegion, date: context.date))
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.secondary.opacity(0.15))
                            .cornerRadius(6)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 8) {
                        Circle()
                            .fill(connectionColor)
                            .frame(width: 10, height: 10)
                        
                        Text(connectionStatus)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel(feedStatusLabel)
                    
                    Spacer()
                    
                    Button(action: {
                        viewModel.toggleFeed()
                    }) {
                        Text(viewModel.connectionState == .connected ? LanguageHelper.stopFeedTitle : LanguageHelper.startFeedTitle)
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(viewModel.connectionState == .connected ? Color.red.opacity(0.15) : Color.blue.opacity(0.15))
                            .foregroundColor(viewModel.connectionState == .connected ? .red : .blue)
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 4)
                
                Picker(LanguageHelper.sortPickerTitle, selection: $viewModel.selectedSortOption) {
                    ForEach(SortOption.allCases) { option in
                        Text(option.localized).tag(option)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                List(viewModel.sortedStocks) { stock in
                    NavigationLink(value: stock.symbol) {
                        StockRowView(
                            stock: stock,
                            fxRate: viewModel.fxRate,
                            currencyCode: viewModel.currencyCode
                        )
                    }
                }
                .listStyle(PlainListStyle())
                .navigationDestination(for: String.self) { symbol in
                    StockDetailView(viewModel: StockDetailViewModel(symbol: symbol, repository: repository))
                }
            }
            .navigationTitle(LanguageHelper.stocksAppTitle)
            .alert(LanguageHelper.connectionFailedError, isPresented: Binding(
                get: { viewModel.connectionError != nil },
                set: { if !$0 { viewModel.connectionError = nil } }
            )) {
                Button(LanguageHelper.ok, role: .cancel) { }
            } message: {
                Text(viewModel.connectionError ?? "")
            }
        }
    }
    
    private var connectionColor: Color {
        switch viewModel.connectionState {
        case .connected: return .green
        case .disconnected: return .red
        case .connecting: return .yellow
        }
    }
    
    //  MARK: - Localization Strings
    private var feedStatusLabel: String {
        return "\(LanguageHelper.feedStatusAccessibility)".replacingOccurrences(of: "%@", with: viewModel.connectionState.rawValue)
    }
    
    private var connectionStatus: String {
        switch viewModel.connectionState {
        case .connected:
            return LanguageHelper.connected
        case .disconnected:
            return LanguageHelper.disconnected
        case .connecting:
            return LanguageHelper.connecting
        }
    }
}
