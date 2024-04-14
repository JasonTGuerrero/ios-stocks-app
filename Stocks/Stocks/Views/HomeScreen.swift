import SwiftUI
import Alamofire

let url = "http://localhost:3000"

struct HomeScreen: View {
    @State private var searchText: String = ""
    @State private var money: String? = nil // Initial value set to nil
//    @State private var money: String? = ""  Initial value set to nil


    
    var body: some View {
        
        if money != nil {
            NavigationView {
                VStack() {
                    DateView()
                        .padding([.leading, .trailing, .bottom])
                    //                    Spacer()
                    PortfolioView(cashBalance: money ?? "")
                        .padding([.leading, .trailing, .top])
                    //                    Spacer(minLength: 10)
                    FavoritesView()
                        .padding([.leading, .trailing, .top])
                    
                    FinnhubLabelView()
                    Spacer(minLength: 1)
                }
                .background(Color(UIColor.secondarySystemBackground))
                .navigationBarTitle("Stocks")
                .searchable(text: $searchText)
                .toolbar {
                    EditButton()
                }
            }
        } else {
            ProgressView {
                Text("Fetching Data...")
            }
                .onAppear {
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
        AF.request("\(url)/money/")
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    if let moneyData = value as? [String: Any],
                       let money = moneyData["money"] as? String {
                        self.money = money
                    }
                case .failure(let error):
                    print(error)
                }
            }
    }
}

#Preview {
    HomeScreen()
}
