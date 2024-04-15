//
//  FavoritesView.swift
//  Stocks
//
//  Created by Jason Guerrero on 4/13/24.
//

import SwiftUI

struct FavoritesView: View {
    var body: some View {
        VStack(spacing: 0) {
            Text("FAVORITES")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 22)
                .padding(.bottom, 5)
//            LazyVStack {
//                NavigationLink(destination: HomeScreen()) {
//                    Text("AAPL")
//                }
//                NavigationLink(destination: HomeScreen()) {
//                    Text("NVDA")
//                }
//                NavigationLink(destination: HomeScreen()) {
//                    Text("TSLA")
//                }
//                NavigationLink(destination: HomeScreen()) {
//                    Text("TSLA")
//                }
//                NavigationLink(destination: HomeScreen()) {
//                    Text("TSLA")
//                }
//                NavigationLink(destination: HomeScreen()) {
//                    Text("TSLA")
//                }
//            }
//            .contentMargins(0)
//            .padding(.top, 0)
//            .padding(.bottom, 0)
        }
        .padding(.bottom, 20)
    }
}

#Preview {
    FavoritesView()
}
