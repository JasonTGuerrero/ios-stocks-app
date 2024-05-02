//
//  FavoritesView.swift
//  Stocks
//
//  Created by Jason Guerrero on 4/13/24.
//

import SwiftUI

struct FavoritesView: View {
    
    @State private var favorites: [String] = ["AAPL", "AAPL", "AAPL", "AAPL"]
    
    var body: some View {
        VStack {
            Text("FAVORITES")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 22)
                .padding(.bottom, 0)
            
//            List($favorites, id: \.self) { $favorite in
//                Text(favorite)
//            }
//            .scrollDisabled(true)
//            .frame(width: 350)
//            .background(Color(UIColor.secondarySystemBackground))
//            .listStyle(PlainListStyle())
        }
        .background(Color(UIColor.secondarySystemBackground))
        .padding(.bottom, 25)
    }
}


#Preview {
    FavoritesView()
}
