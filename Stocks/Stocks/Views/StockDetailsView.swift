//
//  StockDetailsView.swift
//  Stocks
//
//  Created by Jason Guerrero on 4/14/24.
//

import SwiftUI

struct StockDetailsView: View {
    let tickerSymbol: String
    
    var body: some View {
        Text("\(tickerSymbol)")
    }
}

#Preview {
    StockDetailsView(tickerSymbol: "RTX")
}
