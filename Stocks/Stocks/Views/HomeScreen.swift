import SwiftUI

struct HomeScreen: View {
    @State private var searchText = ""
    
    var body: some View {
            NavigationView {
                VStack() {
                    DateView()
                        .padding([.leading, .trailing])
                    Spacer()
                    FinnhubLabelView()
                    Spacer()
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
}

#Preview {
    HomeScreen()
}
