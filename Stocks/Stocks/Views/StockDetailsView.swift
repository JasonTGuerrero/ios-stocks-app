//
//  StockDetailsView.swift
//  Stocks
//
//  Created by Jason Guerrero on 4/14/24.
//

import SwiftUI
import SwiftyJSON
import Alamofire
import Highcharts
import SwiftUI
import UIKit
import WebKit

struct HourlyStockChartWebView: UIViewRepresentable {
    let tickerSymbol: String
    let priceChange: Double
//    private let webView = WKWebView()
    

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator

        // Read the contents of the HTML file
        guard let htmlFilePath = Bundle.main.url(forResource: "hourly", withExtension: "html") else {
            fatalError("HTML file not found")
        }
//        print("HTML file URL:", htmlFilePath)

        do {
            // Read the contents of the HTML file as a String
            let htmlString = try String(contentsOf: htmlFilePath)

            // Replace occurrences of '{tickerSymbol}' and '{priceChange}' with actual values
            let modifiedHTMLString = htmlString
                .replacingOccurrences(of: "{-tickerSymbol-}", with: tickerSymbol)
                .replacingOccurrences(of: "{-priceChange-}", with: String(format: "%.2f", priceChange))
//            print("Modified HTML content:", modifiedHTMLString)

            // Load the modified HTML content into WKWebView
            webView.loadHTMLString(modifiedHTMLString, baseURL: htmlFilePath)
        } catch {
            fatalError("Error loading HTML content: \(error)")
        }

        return webView
    }



    func updateUIView(_ webView: WKWebView, context: Context) {
        // Update the view if needed
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(tickerSymbol: tickerSymbol)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        let tickerSymbol: String

        init(tickerSymbol: String) {
            self.tickerSymbol = tickerSymbol
        }

        // Implement WKNavigationDelegate methods if needed
    }
}

struct HistoricalStockChartWebView: UIViewRepresentable {
    let tickerSymbol: String
//    let priceChange: Double
//    private let webView = WKWebView()
    

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator

        // Read the contents of the HTML file
        guard let htmlFilePath = Bundle.main.url(forResource: "historical", withExtension: "html") else {
            fatalError("HTML file not found")
        }
//        print("HTML file URL:", htmlFilePath)

        do {
            // Read the contents of the HTML file as a String
            let htmlString = try String(contentsOf: htmlFilePath)

            // Replace occurrences of '{tickerSymbol}' and '{priceChange}' with actual values
            let modifiedHTMLString = htmlString
                .replacingOccurrences(of: "{-tickerSymbol-}", with: tickerSymbol)
//                .replacingOccurrences(of: "{-priceChange-}", with: String(format: "%.2f", priceChange))
            print("Modified hist HTML content:", modifiedHTMLString)

            // Load the modified HTML content into WKWebView
            webView.loadHTMLString(modifiedHTMLString, baseURL: htmlFilePath)
        } catch {
            fatalError("Error loading HTML content: \(error)")
        }

        return webView
    }



    func updateUIView(_ webView: WKWebView, context: Context) {
        // Update the view if needed
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(tickerSymbol: tickerSymbol)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        let tickerSymbol: String

        init(tickerSymbol: String) {
            self.tickerSymbol = tickerSymbol
        }

        // Implement WKNavigationDelegate methods if needed
    }
}


struct WebView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView  {
        let wkwebView = WKWebView()
        let request = URLRequest(url: url)
        wkwebView.load(request)
        return wkwebView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
    }
}

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
                    TabView {
                        HourlyStockChartWebView(tickerSymbol: tickerSymbol, priceChange: quoteData?["d"].doubleValue ?? -0.01)
                            .frame(height: 350)
                            .tabItem {
                                Label("Hourly", systemImage: "chart.xyaxis.line")
                            }
                        
                        HistoricalStockChartWebView(tickerSymbol: tickerSymbol)
                            .frame(height: 350)
                            .tabItem { Label("Historical", systemImage: "clock.fill") }
                    }
                    .frame(height: 400)
                    
                        
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
//                    print(self.hourlyChartData!)
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
