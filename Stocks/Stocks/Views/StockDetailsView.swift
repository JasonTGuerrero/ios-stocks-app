//
//  StockDetailsView.swift
//  Stocks
//
//  Created by Jason Guerrero on 4/14/24.
//

import SwiftUI
import SwiftyJSON
import Alamofire

struct StockDetailsView: View {
    let tickerSymbol: String
    @State private var profileData: JSON? = nil
    @State private var quoteData: JSON? = nil
    @State private var hourlyChartData: JSON? = nil
    @State private var isFavorite: Bool = false

    
    var body: some View {
        
        if (profileData == nil
            && quoteData == nil
            && hourlyChartData == nil) {
            ProgressView {
                Text("Fetching Data...")
            }
            .background(Color.white)
            .onAppear {
                fetchProfileData()
                fetchQuoteData()
                fetchHourlyChartData()
            }
        } else {
            NavigationView {
                ScrollView {
                    if let companyName = profileData?["name"].string {
                        Text(companyName)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading)
                            .padding(.top, 10)
                    }
                    
                    HStack {
                        if let stockPrice = quoteData?["c"].double {
                            let priceChange = quoteData?["d"].doubleValue ?? 0.0
                            let percentageChange = quoteData?["dp"].doubleValue ?? 0.0
                            let arrowSymbol = priceChange < 0 ? "arrow.down.forward" : "arrow.up.forward"
                            let arrowColor: Color = priceChange < 0 ? .red : .green
                            
                            Text("$" + String(format: "%.2f", stockPrice))
                                .font(.system(size: 32))
                                .fontWeight(.semibold)
                            Image(systemName: arrowSymbol)
                                .foregroundColor(arrowColor)
                                .font(.system(size: 24))
                            Text("$" + String(format: "%.2f", priceChange))
                                .foregroundColor(arrowColor)
                                .font(.system(size: 24))
                            Text("(\(String(format: "%.2f", percentageChange))%)")
                                .foregroundColor(arrowColor)
                                .font(.system(size: 24))
                        }
                        
                        
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading)
                    .padding(.top, 10)
                        
                }

            }
            .navigationTitle(tickerSymbol)
            .navigationBarTitleDisplayMode(.large) // or .large
            .navigationBarItems(trailing:
                Button(action: {
                    // Action to perform when the button is tapped
                    isFavorite.toggle()
                }) {
                    Image(systemName: isFavorite ? "plus.circle.fill" : "plus.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fit) // or .fill
                        .frame(width: 24, height: 24) // Adjust the width and height as needed
                }
            )

        }
        
    }
    
    func fetchProfileData() {
        AF.request("\(url)/company-profile/\(tickerSymbol)").validate().responseJSON { response in
            switch response.result {
            case .success:
                if let profileData = response.data {
                    self.profileData = JSON(profileData)
//                    print(self.profileData!)
                }

            case .failure(let error):
                print("Error fetching company profile results:", error)
            }
        }
    }
    
    func fetchQuoteData() {
        AF.request("\(url)/company-quote/\(tickerSymbol)").validate().responseJSON { response in
            switch response.result {
            case .success:
                if let quoteData = response.data {
                    self.quoteData = JSON(quoteData)
//                    print(self.quoteData!)
                }

            case .failure(let error):
                print("Error fetching company quote results:", error)
            }
        }
    }
    
    func fetchHourlyChartData() {
        AF.request("\(url)/stock-hourly-chart/\(tickerSymbol)").validate().responseJSON { response in
            switch response.result {
            case .success:
                if let hourlyChartData = response.data {
                    self.hourlyChartData = JSON(hourlyChartData)
                    print(self.hourlyChartData!)
                }

            case .failure(let error):
                print("Error fetching hourly stock data:", error)
            }
        }
    }
}

#Preview {
    StockDetailsView(tickerSymbol: "AAPL")
}
