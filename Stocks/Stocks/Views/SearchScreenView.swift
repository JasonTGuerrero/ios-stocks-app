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
    @State private var isFavorite = false


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
        .navigationBarItems(trailing:
            Button(action: {
                // Add action for the plus button here
                isFavorite.toggle()
            }) {
                Image(systemName: isFavorite ? "plus.circle.fill" : "plus.circle")
            }
        )
        .onAppear {
            fetchAutocompleteResults()
        }
        .onChange(of: searchText) { newValue in
            // Cancel previous debounce work item
            debounceWorkItem?.cancel()
            // Schedule new debounce work item
            let newWorkItem = DispatchWorkItem {
                fetchAutocompleteResults()
            }
            debounceWorkItem = newWorkItem
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: debounceWorkItem!)
        }
    }


    func fetchAutocompleteResults() {
        let currentSearchText = searchText // Capture the current value of searchText
        AF.request("\(url)/stock-search/\(currentSearchText)").validate().responseJSON { response in
            switch response.result {
            case .success:
                if currentSearchText == self.searchText { // Check if searchText has changed
                    if let autocompleteData = response.data {
                        let autocompleteJSON = JSON(autocompleteData)
                        let results = autocompleteJSON.arrayValue.map { json in
                            SearchResult(symbol: json["symbol"].stringValue, description: json["description"].stringValue)
                        }
                        searchResults = results
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
