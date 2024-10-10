//
//  ContentView.swift
//  Biteary
//
//  Created by Rodrigo Llaguno on 10/10/24.
//

import SwiftUI

struct ContentView: View {
    @State private var searchText: String = ""
    @State private var isSearching: Bool = false

    
    var body: some View {
        NavigationStack {
            VStack {
                
                ScrollView {
                    LazyVStack {
                        //ForEach(folders) { folder in
                            //FolderCard(folder: folder)
                        //}
                    }
                }
                
                Spacer()
                
                NavigationLink {
                    //somewhere
                } label: {
                    ZStack {
                        Circle()
                            .fill(.orange)
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "plus")
                            .foregroundStyle(.white)
                            .font(.title.bold())
                    }
                    
                }
                
                
            }
            .navigationTitle("Biteary")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isSearching.toggle()
                    } label: {
                        Image(systemName: "magnifyingglass")
                    }
            }
                
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu(content: {
                        Text("Order Alphabetically")
                        Text("Order by Newest")
                        Text("Order by Oldest")
                    }, label: {Image(systemName: "ellipsis.circle")})
                }
            }
            .if(isSearching) { view in
                view.searchable(text: $searchText)
            }
            
        }
    }
}

extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, content: (Self) -> Content) -> some View {
        if condition {
            content(self)
        } else {
            self
        }
    }
}

#Preview {
    ContentView()
}
