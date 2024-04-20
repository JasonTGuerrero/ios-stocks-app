//
//  SearchScreenView.swift
//  Stocks
//
//  Created by Jason Guerrero on 4/14/24.
//

import SwiftUI
import Alamofire
import SwiftyJSON

struct SearchResult: Identifiable, Hashable {
    var id = UUID() // Unique identifier for each search result
    var symbol: String
    var description: String
}

struct SearchScreenView: View {
    @Binding var searchText: String
    @State private var searchResults: [SearchResult] = []
    @State private var debounceWorkItem: DispatchWorkItem?


    var body: some View {
        List(searchResults) { result in
            NavigationLink(destination: StockDetailsView(tickerSymbol: result.symbol)) {
                VStack(alignment: .leading) {
                    Text(result.symbol)
                        .font(.system(size: 22))
                        .fontWeight(.bold)
                        
                    Text(result.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
        }
        .navigationBarTitle("Stocks", displayMode: .inline)
        .onAppear {
            fetchAutocompleteResults()
        }
        .onChange(of: searchText) {
            // Cancel previous debounce work item
            debounceWorkItem?.cancel()
            // Schedule new debounce work item
            let newWorkItem = DispatchWorkItem {
                fetchAutocompleteResults()
            }
            debounceWorkItem = newWorkItem
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: debounceWorkItem!)
        }
    }


    func fetchAutocompleteResults() {
        print("fetching autocomplete results...")
        let currentSearchText = searchText // Capture the current value of searchText
        AF.request("\(url)/stock-search/\(currentSearchText)").validate().responseJSON { response in
            switch response.result {
            case .success:
                if currentSearchText == self.searchText { // Check if searchText has changed
                    if let autocompleteData = response.data {
                        do {
                            let autocompleteJSON = try JSON(data: autocompleteData)
//                            print("autocompleteJSON: ", autocompleteJSON)
                            let results = autocompleteJSON["result"].arrayValue.map { json in
                                SearchResult(symbol: json["symbol"].stringValue, description: json["description"].stringValue)
                            }
                            DispatchQueue.main.async {
                                searchResults = results // Update searchResults on the main queue
//                                print("searchResults: ", results)
                            }
                        } catch {
                            print("Error parsing JSON:", error)
                        }
                    }
                }
            case .failure(let error):
                print("Error fetching autocomplete results:", error)
                // Handle request failure
            }
        }
    }

}

#Preview {
    SearchScreenView(searchText: .constant(""))
}
