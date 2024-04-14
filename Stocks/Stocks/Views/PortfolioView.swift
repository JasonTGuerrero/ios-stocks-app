//
//  PortfolioView.swift
//  Stocks
//
//  Created by Jason Guerrero on 4/12/24.
//

import SwiftUI

struct PortfolioView: View {
    
    @Binding var cashBalance: Float?

    var body: some View {
        VStack(spacing: 0) {
            Text("PORTFOLIO")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 22)
                .padding(.bottom, 6)
            HStack {
                VStack {
                    Text("Net Worth")
                        .fontWeight(.none)
                        .font(.system(size: 22))
                        .frame(maxWidth: .infinity, maxHeight: 35, alignment: .leading)
                        .padding(.top, -2)
                        .padding(.leading, 7)
                    Text("$" + String(format: "%.2f", cashBalance!))
                        .font(.system(size: 22))
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 5)
                        .padding(.top, -10)
                    
                }
                Spacer()
                VStack {
                    Text("Cash Balance")
                        .fontWeight(.none)
                    .font(.system(size: 22))
                    Text("$" + String(format: "%.2f", cashBalance!))
//                    Text("$\(String(describing: cashBalance))")
                        .font(.system(size: 22))
                        .fontWeight(.bold)
                        .padding(.trailing, 10)
                }
                
            }
            .foregroundColor(.primary)
            .padding(10)
            .padding(.leading, 5)
            .padding(.trailing, 5)
            .padding(.top, 5)
            .background(Color.white)
            .cornerRadius(12)
        }
        .padding(.bottom, 0)
    }
}

#Preview {
    PortfolioView(cashBalance: .constant(25000.00))
}
