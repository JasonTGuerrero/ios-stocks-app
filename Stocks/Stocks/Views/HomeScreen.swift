import SwiftUI
import Alamofire

let url = "http://localhost3000"

struct HomeScreen: View {
    @State private var searchText: String = ""
    @State private var money: String = ""

    
    var body: some View {
        
        var _: Float = 0.0
        
            NavigationView {
                VStack() {
                    DateView()
                        .padding([.leading, .trailing, .bottom])
//                    Spacer()
                    PortfolioView()
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
                        print(self.money)
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
