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


struct PillButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(Color.green)
            )
            .foregroundColor(.white)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1))
    }
}

struct SocialSentimentsTableView: View {
    let data: JSON
    let companyName: String

    var body: some View {
        Grid(horizontalSpacing: 30, verticalSpacing: 15) {
            // Header row
            GridRow {
                Text(companyName).fontWeight(.bold)
                Text("MSPR").fontWeight(.bold)
                Text("Change").fontWeight(.bold)
            }
            Divider()
            // Total row
            GridRow {
                Text("Total").fontWeight(.bold)
                Text(String(format: "%.2f", data["total_mspr"].double ?? 0))
                Text(String(format: "%.2f", data["total_change"].double ?? 0))
            }
            Divider()
            // Positive row
            GridRow {
                Text("Positive").fontWeight(.bold)
                Text(String(format: "%.2f", data["positive_mspr"].double ?? 0))
                Text(String(format: "%.2f", data["positive_change"].double ?? 0))
            }
            Divider()
            // Negative row
            GridRow {
                Text("Negative").fontWeight(.bold)
                Text(String(format: "%.2f", data["negative_mspr"].double ?? 0))
                Text(String(format: "%.2f", data["negative_change"].double ?? 0))
            }
            Divider()
        }
        .padding()
    }
}

struct StockDetailsView: View {
    let tickerSymbol: String
    @State private var profileData: JSON? = nil
    @State private var quoteData: JSON? = nil
    @State private var hourlyChartData: JSON? = nil
    @State private var companyPeersData: JSON? = nil
    @State private var socialSentimentsData: JSON? = nil
    @State private var trendsData: JSON? = nil
    @State private var isFavorite: Bool = false

    
    var body: some View {
        
        if (profileData == nil
            && quoteData == nil
            && companyPeersData == nil
            && socialSentimentsData == nil
            && trendsData == nil) {
            ProgressView {
                Text("Fetching Data...")
            }
            .background(Color.white)
            .onAppear {
                fetchProfileData()
                fetchQuoteData()
                fetchCompanyPeersData()
                fetchSocialSentiments()
                fetchTrendsData()
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
//                        if let priceChange = quoteData?["d"].doubleValue {
//                        HourlyStockChartWebView(tickerSymbol: tickerSymbol, priceChange: priceChange)
//                            .frame(height: 350)
//                            .tabItem {
//                                Label("Hourly", systemImage: "chart.xyaxis.line")
//                            }
//                        }
//
//                        HistoricalStockChartWebView(tickerSymbol: tickerSymbol)
//                            .frame(height: 350)
//                            .tabItem {
//                                Label("Historical", systemImage: "clock.fill")
//                            }
                    }
                    .frame(height: 400)
//                    .padding(.bottom, 20)
                    
                    VStack(alignment: .leading, content: {
                        Text("Portfolio")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading)
//                            .padding(.bottom)
                            .font(.system(size: 26))
                            
                    })
                    HStack {
                        VStack {
                            Text("You have 0 shares of \(tickerSymbol).")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.system(size: 16))
                                .padding(.bottom, 0.01)
                                .padding(.leading)
                            Text("Start trading!")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.system(size: 16))
                                .padding(.leading)
                        }
                        .frame(width: 215)
                        VStack {
                            Button("Trade") {
                                
                            }
                            .padding(20)
                            .frame(width: 150)
                            .background(Color.green)
                            .foregroundStyle(.white)
                            .fontWeight(.bold)
                            .clipShape(Capsule())
                        }
                        .padding(.leading)
                        .padding(.trailing)
                    }
                    VStack(alignment: .leading, content: {
                        Text("Stats")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading)
                            .padding(.top)
                            .font(.system(size: 26))
                            
                    })
                    HStack {
                        VStack(spacing: 0) {
                            HStack {
                                Text("High Price:")
                                    .font(.system(size: 15))
                                    .bold()
                                Text("$"+String(format: "%.2f", quoteData?["h"].double ?? 0.0))
                                    .padding(.trailing, 20)
                                    .font(.system(size: 15))
                                Text("Open Price:")
                                    .font(.system(size: 15))
                                    .bold()
                                Text("$"+String(format: "%.2f", quoteData?["o"].double ?? 0.0))
                                    .font(.system(size: 15)) // Set font size to 15
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .padding(.leading, 5)
                            HStack {
                                Text("Low Price:")
                                    .font(.system(size: 15))
                                    .bold()
                                Text("$"+String(format: "%.2f", quoteData?["l"].double ?? 0.0))
                                    .padding(.trailing, 24)
                                    .font(.system(size: 15))
                                Text("Prev. Close:")
                                    .font(.system(size: 15))
                                    .bold()
                                Text("$"+String(format: "%.2f", quoteData?["pc"].double ?? 0.0))
                                    .font(.system(size: 15))
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading)
                            .padding(.leading, 5)
                        }
                    }

                    VStack(alignment: .leading, content: {
                        Text("About")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading)
                            .padding(.top)
                            .padding(.bottom)
                            .font(.system(size: 26))
                            
                    })
                    VStack {
                        HStack {
                            Text("IPO Start Date:\t\t")
                                .bold()
                                .font(.system(size: 16))
                            Text("\(profileData?["ipo"] ?? "")")
                                .font(.system(size: 16))

                            
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 30)
                        .padding(.bottom, 0)
                        
                        HStack {
                            Text("Industry:\t\t\t\t")
                                .bold()
                                .font(.system(size: 16))
                            Text("\(profileData?["finnhubIndustry"] ?? "")")
                                .font(.system(size: 16))

                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 30)
                        .padding(.top, 1)
                        
                        HStack {
                            Text("Webpage:\t\t\t\t")
                                .font(.system(size: 16))
                                .bold()
                            if let webURLString = profileData?["weburl"].string,
                               let webURL = URL(string: webURLString) {
                                Link(webURLString, destination: webURL)
                                    .font(.system(size: 16))
                            } else {
                                Text("N/A")
                            }
                            
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 30)
                        .padding(.top, 1)
                        
                        HStack {
                            Text("Company Peers:\t\t")
                                .font(.system(size: 16))

                                .bold()
                            ScrollView(.horizontal) {
                                HStack {
                                    if let companyPeers = companyPeersData?.array {
                                        ScrollView(.horizontal) {
                                            HStack(spacing: 10) {
                                                ForEach(0..<companyPeers.count, id: \.self) { index in
                                                    if let peer = companyPeers[index].string {
                                                        NavigationLink(destination: StockDetailsView(tickerSymbol: peer)) {
                                                                   Text(peer + ",")
                                                                    .font(.system(size: 16))
                                                               }

                                                    }
                                                }
                                            }
                                        }
                                    } else {
                                        Text("No company peers available")
                                    }
                                }

                            }
                            
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 30)
                        .padding(.top, 0)

                    
                        VStack(alignment: .leading, content: {
                            Text("Insights")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading)
                                .padding(.top)
                                .font(.system(size: 26))
                            
                        })
                        Text("Social Sentiments")
                            .frame(alignment: .center)
                            .font(.system(size: 24))
                            .padding(.top)
                        if let socialSentimentsData = self.socialSentimentsData {
                            if let companyName = profileData?["name"].string {
                                SocialSentimentsTableView(data: socialSentimentsData, companyName: companyName)
                                    .frame(width: 400)
                            }
                        }
                        StackColumnChartView()
                            .frame(height: 300)
                        
                    }
                    
                        
                }

            }
            .navigationTitle(tickerSymbol)
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(trailing:
                Button(action: {
                    isFavorite.toggle()
                }) {
                    Image(systemName: isFavorite ? "plus.circle.fill" : "plus.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                }
            )

        }
        
    }
    

    struct StackColumnChartView: UIViewRepresentable {
//        let options: HIOptions
        
        func makeUIView(context: Context) -> HIChartView {
            let chartView = HIChartView()

            let options = HIOptions()

            let chart = HIChart()
            chart.type = "column"
            options.chart = chart

            let title = HITitle()
            title.text = "Stacked column chart"
            options.title = title

            let xAxis = HIXAxis()
            xAxis.categories = ["Apples", "Oranges", "Pears", "Grapes", "Bananas"]
            options.xAxis = [xAxis]

            let yAxis = HIYAxis()
            yAxis.min = 0
            yAxis.title = HITitle()
            yAxis.title.text = "Total fruit consumption"
            yAxis.stackLabels = HIStackLabels()
            yAxis.stackLabels.enabled = true
            yAxis.stackLabels.style = HICSSObject()
            yAxis.stackLabels.style.fontWeight = "bold"
            yAxis.stackLabels.style.color = "gray"
            options.yAxis = [yAxis]

            let legend = HILegend()
            legend.align = "right"
            legend.x = -30
            legend.verticalAlign = "top"
            legend.y = 25
            legend.floating = true
            legend.backgroundColor = HIColor(name: "white")
            legend.borderColor = HIColor(hexValue: "CCC")
            legend.borderWidth = 1
            legend.shadow = HICSSObject()
            legend.shadow.opacity = 0
            options.legend = legend

            let tooltip = HITooltip()
            tooltip.headerFormat = "<b>{point.x}</b><br/>"
            tooltip.pointFormat = "{series.name}: {point.y}<br/>Total: {point.stackTotal}"
            options.tooltip = tooltip

            let plotOptions = HIPlotOptions()
            plotOptions.series = HISeries()
            plotOptions.series.stacking = "normal"
            let dataLabels = HIDataLabels()
            dataLabels.enabled = true
            plotOptions.series.dataLabels = [dataLabels]
            options.plotOptions = plotOptions

            let john = HIColumn()
            john.name = "John"
            john.data = [5, 3, 4, 7, 2]

            let jane = HIColumn()
            jane.name = "Jane"
            jane.data = [2, 2, 3, 2, 1]

            let joe = HIColumn()
            joe.name = "Joe"
            joe.data = [3, 4, 4, 2, 5]

            options.series = [john, jane, joe]

            chartView.options = options
            return chartView
        }
        
        func updateUIView(_ uiView: HIChartView, context: Context) {
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
    
    func fetchCompanyPeersData() {
        AF.request("\(url)/company-peers/\(tickerSymbol)").validate().responseJSON { response in
            switch response.result {
            case .success:
                if let peersData = response.data {
                    self.companyPeersData = JSON(peersData)
//                    print(self.companyPeers!)
                }

            case .failure(let error):
                print("Error fetching company peers data:", error)
            }
        }
    }
    
    func fetchSocialSentiments() {
        AF.request("\(url)/insider-sentiment/\(tickerSymbol)").validate().responseJSON { response in
            switch response.result {
            case .success:
                if let socialSentimentsData = response.data {
                    self.socialSentimentsData = JSON(socialSentimentsData)
//                    print(self.socialSentimentsData!)
                }

            case .failure(let error):
                print("Error fetching social sentiments data:", error)
            }
        }
    }
    
    func fetchTrendsData() {
        AF.request("\(url)/recommendation-trends/\(tickerSymbol)").validate().responseJSON { response in
            switch response.result {
            case .success:
                if let trendsData = response.data {
                    self.trendsData = JSON(trendsData)
                    print(self.trendsData!)
                }

            case .failure(let error):
                print("Error fetching recommendation trends data:", error)
            }
        }
    }

}

#Preview {
    StockDetailsView(tickerSymbol: "AAPL")
}
