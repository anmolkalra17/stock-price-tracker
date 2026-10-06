//
//  Stock_Price_TrackerApp.swift
//  Stock Price Tracker
//
//  Created by Anmol Kalra on 05/10/26.
//

import SwiftUI

@main
struct Stock_Price_TrackerApp: App {
    
    @State private var repo = StockRepository()
    
    var body: some Scene {
        WindowGroup {
            StockListView(repository: repo)
        }
    }
}
