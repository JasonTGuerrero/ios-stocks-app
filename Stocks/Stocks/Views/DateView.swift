//
//  DateView.swift
//  Stocks
//
//  Created by Jason Guerrero on 4/10/24.
//

import SwiftUI

struct DateView: View {
    
    var body: some View {
            Text(currentDate())
            .frame(maxWidth: .infinity, maxHeight: 35, alignment: .leading)
            .fontWeight(.bold)
            .font(.title)
            .foregroundColor(.secondary)
            .padding(.top, 15)
            .padding(.bottom, 15)
            .padding(.leading, 20)
            .padding(.trailing, 20)
//            .padding(20)
            .background(Color.white)
            .cornerRadius(15)
    }
    
    func currentDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter.string(from: Date())
    }
}

#Preview {
    DateView()
}
