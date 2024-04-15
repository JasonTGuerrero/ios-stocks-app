import SwiftUI
import Alamofire
import SwiftyJSON

let url = "http://localhost:3000"

struct HomeScreen: View {
    @State private var searchText: String = ""
    @State private var money: Float? = nil // Initial value set to nil
//    @State private var money: String? = ""  Initial value set to nil


    
    var body: some View {
        
        if money != nil {
            
            NavigationView {
                if searchText == "" {
                    ScrollView {
                        //                    if searchText == "" {
                        DateView()
                            .padding([.leading, .trailing, .bottom])
                        PortfolioView(cashBalance: $money)
                            .padding([.leading, .trailing, .top])
                        FavoritesView()
                            .padding([.leading, .trailing, .top])
                        
                        FinnhubLabelView()
                        Spacer(minLength: 1)
                        //                    }
                        //                    else {
                        //                        SearchScreenView()
                        //                    }
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
                        // Handle conversion failure
                    }
                }
            case .failure(let error):
                print("Error fetching money:", error)
                // Handle request failure
            }
        }
    }
}

#Preview {
    HomeScreen()
}
