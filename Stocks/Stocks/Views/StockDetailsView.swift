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
import Kingfisher
import SwiftUI
import UIKit
import WebKit
import Foundation

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
    @State private var earningsData: JSON? = nil
    @State private var newsData: JSON? = nil
    @State private var isFavorite: Bool = false

    
    var body: some View {
        
        if (profileData == nil
            && quoteData == nil
            && companyPeersData == nil
            && socialSentimentsData == nil
            && trendsData == nil
            && earningsData == nil
            && newsData == nil) {
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
                fetchEarningsData()
                fetchNewsData()
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

                        if let trendsData = self.trendsData {
                            recommendationTrendsView(recommendationTrendsData: trendsData)
                                .frame(height: 400)
                                .padding(.top, 55)
                        }
                        
                        if let companyEarningsData = self.earningsData {
                            companyEarningsView(companyEarningsData: companyEarningsData)
                                .frame(height: 430)
                                .padding(.top, 55)
                        }
                        
                        Text("News")
                            .font(.system(size: 26))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading)
                            .padding(.top)
                            .padding(.bottom, -55)

                            
                        if let newsData = self.newsData {
                            CompanyNewsView(newsData: newsData.arrayValue)
                        }

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
    
    struct CompanyNewsView: View {
        let newsData: [JSON]
        
        var body: some View {
            Group {
                KFImage(URL(string: "\(newsData[0]["image"])"))
                    .resizable()
                    .cornerRadius(10)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 360, height: 360)
                    .padding(.bottom, -35)
                VStack {
                    HStack {
                        Text("\(newsData[0]["source"])")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .fontWeight(.bold)
                        +
                        Text("  \(timeSince(from: newsData[0]["datetime"].doubleValue))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 18)
                    Text("\(newsData[0]["headline"])")
                        .fontWeight(.bold)
//                        .padding(.top, 0.1)
                }
                Divider()
                    .padding(.bottom, 2)
            }
            HStack {
                VStack {
                    HStack {
                        Text("\(newsData[1]["source"])")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .fontWeight(.bold)
                        +
                        Text("  \(timeSince(from: newsData[1]["datetime"].doubleValue))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 1)
                    Text("\(newsData[1]["headline"])")
                        .fontWeight(.bold)
                }
                VStack {
                    KFImage(URL(string: "\(newsData[1]["image"])"))
                        .resizable()
                        .cornerRadius(10)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                }
            }
            .padding(.horizontal, 12)
            
        }
        
        func timeSince(from epochTime: TimeInterval) -> String {
            let currentDate = Date()
            let epochDate = Date(timeIntervalSince1970: epochTime)
            let interval = currentDate.timeIntervalSince(epochDate)
            
            let hours = Int(interval / 3600)
            let minutes = Int((interval.truncatingRemainder(dividingBy: 3600)) / 60)
            
            var timeString = ""
            
            if hours > 0 {
                timeString += "\(hours) hr"
            }
            
            if minutes > 0 {
                timeString += ", \(minutes) min"
            }
            
            return timeString
        }
    }
    
    struct NewsView: UIViewRepresentable {
        let newsData: JSON
        
        func makeUIView(context: Context) -> some UIView {
//            print("newsData: ", newsData)
            print("image:", newsData[0]["image"])
            return UIView()
        }
        
        func updateUIView(_ uiView: UIViewType, context: Context) {
        }
    }
    
    struct companyEarningsView: UIViewRepresentable {
        let companyEarningsData: JSON
        
        func makeUIView(context: Context) -> some UIView {
            var actuals: [[Any]] = []
            var estimates: [[Any]] = []
            var periods: [String] = []
            var surprises: [String] = []
            var combinedLabels: [String] = []
            for datum in companyEarningsData {
                var actualPair: [Any] = []
                var estimatePair: [Any] = []
                actualPair = ["Surprise: " + datum.1["surprise"].stringValue, datum.1["actual"].doubleValue]
                estimatePair = [datum.1["period"].stringValue, datum.1["estimate"].doubleValue]
                actuals.append(actualPair)
                estimates.append(estimatePair)
                periods.append(datum.1["period"].stringValue)
                surprises.append("Surprise: " + datum.1["surprise"].stringValue)
                combinedLabels.append(datum.1["period"].stringValue + "<br/>" + "Surprise: " + datum.1["surprise"].stringValue)
            }
            let chartView = HIChartView()
            
            let estimateSeries = HISpline()
            estimateSeries.data = estimates
            estimateSeries.name = "Estimate"
            estimateSeries.marker = HIMarker()
            estimateSeries.xAxis = 0

            
            let actualSeries = HISpline()
            actualSeries.data = actuals
            actualSeries.marker = HIMarker()
            actualSeries.name = "Actual"
//            actualSeries.xAxis = 0
            
            let periodAxis = HIXAxis()
            periodAxis.categories = periods
            let surprisesAxis = HIXAxis()
            surprisesAxis.categories = surprises
            let combinedAxis = HIXAxis()
            combinedAxis.categories = combinedLabels
            combinedAxis.labels = HILabels()
            combinedAxis.labels.rotation = -45

            let options = HIOptions()
            options.xAxis = [combinedAxis]
            options.series = [actualSeries, estimateSeries]

            let chart = HIChart()
            chart.type = "spline"
            options.chart = chart

            let title = HITitle()
            title.text = "Historical EPS Surprises"
            options.title = title


            let yAxis = HIYAxis()
            yAxis.title = HITitle()
            yAxis.title.text = "Quarterly EPS"
            options.yAxis = [yAxis]

            let legend = HILegend()
            legend.enabled = true
            options.legend = legend
            
            
            let tooltip = HITooltip()
            tooltip.headerFormat = "{point.x}<br/>"
            tooltip.shared = true
            options.tooltip = tooltip
            

            let plotOptions = HIPlotOptions()
            plotOptions.spline = HISpline()
            plotOptions.spline.marker = HIMarker()
            plotOptions.spline.marker.enabled = true
            options.plotOptions = plotOptions

            chartView.options = options
            return chartView
        }
        
        func updateUIView(_ uiView: UIViewType, context: Context) {
        }
    }
    

    struct recommendationTrendsView: UIViewRepresentable {
        let recommendationTrendsData: JSON
        
        func makeUIView(context: Context) -> HIChartView {
            let chartView = HIChartView()

            let options = HIOptions()

            let chart = HIChart()
            chart.type = "column"
            options.chart = chart

            let title = HITitle()
            title.text = "Recommendation Trends"
            options.title = title

            let xAxis = HIXAxis()
            var xCategories: [String] = []
            var buys: [Int] = []
            var sells: [Int] = []
            var strongBuys: [Int] = []
            var strongSells: [Int] = []
            var holds: [Int] = []
            for trend in recommendationTrendsData {
                xCategories.append(trend.1["period"].stringValue)
                buys.append(trend.1["buy"].intValue)
                sells.append(trend.1["sell"].intValue)
                strongBuys.append(trend.1["strongBuy"].intValue)
                strongSells.append(trend.1["strongSell"].intValue)
                holds.append(trend.1["hold"].intValue)
            }
            xAxis.categories = xCategories
            options.xAxis = [xAxis]

            let yAxis = HIYAxis()
            yAxis.min = 0
            yAxis.title = HITitle()
            yAxis.title.text = "#Analysis"
            yAxis.stackLabels = HIStackLabels()
            yAxis.stackLabels.enabled = false
            yAxis.stackLabels.style = HICSSObject()
            yAxis.stackLabels.style.fontWeight = "bold"
            yAxis.stackLabels.style.color = "gray"
            yAxis.tickInterval = 20
            options.yAxis = [yAxis]

            let legend = HILegend()
            legend.align = "right"
            legend.x = -30
            legend.verticalAlign = "bottom"
            legend.y = 25
            legend.floating = true
            legend.backgroundColor = HIColor(name: "white")
            legend.borderColor = HIColor(hexValue: "CCC")
            legend.borderWidth = 1
            legend.shadow = HICSSObject()
            legend.shadow.opacity = 0

            let tooltip = HITooltip()
            tooltip.headerFormat = "<b>{point.x}</b><br/>"
            tooltip.pointFormat = "{series.name}: {point.y}<br/>"
            options.tooltip = tooltip

            let plotOptions = HIPlotOptions()
            plotOptions.series = HISeries()
            plotOptions.series.stacking = "normal"
            let dataLabels = HIDataLabels()
            dataLabels.enabled = true
            plotOptions.series.dataLabels = [dataLabels]
            options.plotOptions = plotOptions
            
            let buy = HIColumn()
            buy.name = "Buy"
            buy.data = buys
            buy.color = HIColor(hexValue: "1DB954")
            
            let strongBuy = HIColumn()
            strongBuy.name = "Strong Buy"
            strongBuy.data = strongBuys
            strongBuy.color = HIColor(hexValue: "176F38")
            
            let sell = HIColumn()
            sell.name = "Sell"
            sell.data = sells
            sell.color = HIColor(hexValue: "F45B5B")
            
            let strongSell = HIColumn()
            strongSell.name = "Strong Sell"
            strongSell.data = strongSells
            strongSell.color = HIColor(hexValue: "813131")
            
            let hold = HIColumn()
            hold.name = "Hold"
            hold.data = holds
            hold.color = HIColor(hexValue: "B98B1D")

            let john = HIColumn()
            john.name = "John"
            john.data = [5, 3, 4, 7, 2]

            let jane = HIColumn()
            jane.name = "Jane"
            jane.data = [2, 2, 3, 2, 1]

            let joe = HIColumn()
            joe.name = "Joe"
            joe.data = [3, 4, 4, 2, 5]

            options.series = [strongBuy, buy, hold, sell, strongSell]

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
//                    print(self.trendsData!)
                }

            case .failure(let error):
                print("Error fetching recommendation trends data:", error)
            }
        }
    }
    
    func fetchEarningsData() {
        AF.request("\(url)/company-earnings/\(tickerSymbol)").validate().responseJSON { response in
            switch response.result {
            case .success:
                if let earningsData = response.data {
                    self.earningsData = JSON(earningsData)
//                    print(self.earningsData!)
                }

            case .failure(let error):
                print("Error fetching company earnings data:", error)
            }
        }
    }
    
    func fetchNewsData() {
        AF.request("\(url)/company-news/\(tickerSymbol)").validate().responseJSON { response in
            switch response.result {
            case .success:
                if let newsData = response.data {
                    self.newsData = JSON(newsData)
                    print(self.newsData!)
                }

            case .failure(let error):
                print("Error fetching company earnings data:", error)
            }
        }
    }

}

#Preview {
    StockDetailsView(tickerSymbol: "AAPL")
}
