import SwiftUI
import Alamofire
import SwiftyJSON

//let url = "http://localhost:3000"
let url = "https://ios-api-422003.wl.r.appspot.com"

struct Stock: Identifiable {
    let id = UUID()
    let symbol: String
    var currentPrice: Double
    var priceChange: Double
    var percentChange: Double
}

class FavoritesViewModel: ObservableObject {
    @Published var favoriteStocks: [Stock] = [Stock(symbol: "AAPL", currentPrice: 0.00, priceChange: 0.00, percentChange: 0.00)]
    
    func addToFavorites(stock: Stock) {
        favoriteStocks.append(stock)
    }
    
    func removeFromFavorites(stock: Stock) {
        if let index = favoriteStocks.firstIndex(where: { $0.id == stock.id }) {
            favoriteStocks.remove(at: index)
        }
    }
}

struct HomeScreen: View {
    @State private var searchText: String = ""
    @State private var money: Float? = nil
    @State private var favoritesList: [Stock]? = nil
    @StateObject var favorites: FavoritesViewModel = FavoritesViewModel()


    
    var body: some View {
        
        if money != nil {
            
            NavigationView {
                if searchText == "" {
                    ScrollView {
                        DateView()
                            .padding([.leading, .trailing, .bottom])
                        PortfolioView(cashBalance: $money)
                            .padding([.leading, .trailing, .top])
                        FavoritesView()
                            .padding([.leading, .trailing, .top])
                        
                        FinnhubLabelView()
                    }
                    .background(Color(UIColor.secondarySystemBackground))
                    .navigationBarTitle("Stocks")
                    .toolbar {
                        EditButton()
                    }
                } else {
                    SearchScreenView(searchText: $searchText)
                }
            }
            .searchable(text: $searchText)
        } else {
            ProgressView {
                Text("Fetching Data...")
            }
            .background(Color.white)
            .onAppear {
                print("calling fetchMoney")
                fetchMoney()
            }
        }
        
    }
    
    func currentDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter.string(from: Date())
    }
    
    func fetchMoney() {
        AF.request("\(url)/money/").validate().responseJSON { response in
            switch response.result {
            case .success:
                if let moneyData = response.data {
                    let moneyJSON = JSON(moneyData)
                    let money = moneyJSON["money"].stringValue
                    if let moneyFloat = Float(money) {
                        print("Money float value:", moneyFloat)
                        self.money = moneyFloat
                    } else {
                        print("Failed to convert money to float")
                    }
                }
            case .failure(let error):
                print("Error fetching money:", error)
            }
        }
    }
}

#Preview {
    HomeScreen()
}
