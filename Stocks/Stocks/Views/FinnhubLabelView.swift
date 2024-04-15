//
//  FinnhubLabelView.swift
//  Stocks
//
//  Created by Jason Guerrero on 4/10/24.
//

import SwiftUI

struct FinnhubLabelView: View {
    var body: some View {
            Button(action: {
                if let url = URL(string: "http://finnhub.io") {
                    UIApplication.shared.open(url)
                }
            }) {
                Text("Powered by Finnhub.io")
                    .frame(maxWidth: .infinity, minHeight: 45)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .background(Color.white)
                    .cornerRadius(13)
                    .padding(.leading, 20)
                    .padding(.trailing, 20)
                    .padding(.top, 0)
//                    .padding(.bottom, 120)
                    .contentMargins(0)
            }
        }
}

#Preview {
    FinnhubLabelView()
}
