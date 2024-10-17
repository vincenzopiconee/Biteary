//
//  ContentView.swift
//  Biteary
//
//  Created by Rodrigo Llaguno on 10/10/24.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) var modelContext
    @Query var folders: [Folder]
    
    @State private var searchText: String = ""
    @State private var searchIsActive = false
    @State private var isShowingCreateFolderView: Bool = false
    @State private var sortOrder = [
        SortDescriptor(\Folder.dateCreated, order: .reverse),
        SortDescriptor(\Folder.name)
    ]
    
    var body: some View {
        NavigationStack {
            VStack {
                if folders.isEmpty {
                    WelcomeScreenView(type: "folder")
                } else {
                    FolderListView(sort: sortOrder, searchString: searchText)
                }
                
                Spacer()
                
                Button {
                    isShowingCreateFolderView.toggle()
                } label: {
                    AddButton()
                }
                
            }
            .padding()
            .navigationTitle("Biteary")
            .toolbar {
                Menu("Sort", systemImage: "arrow.up.arrow.down") {
                    Picker("Sort", selection: $sortOrder) {
                        Text("Sort by Newest")
                            .tag([
                                SortDescriptor(\Folder.dateCreated, order: .reverse),
                                SortDescriptor(\Folder.name)
                            ])
                        
                        Text("Sort by Oldest")
                            .tag([
                                SortDescriptor(\Folder.dateCreated),
                                SortDescriptor(\Folder.name)
                            ])
                        
                        Text("Sort by Name")
                            .tag([
                                SortDescriptor(\Folder.name),
                                SortDescriptor(\Folder.dateCreated)
                            ])
            
                        Text("Sort by Start Date")
                            .tag([
                                SortDescriptor(\Folder.startDate),
                                SortDescriptor(\Folder.dateCreated)
                            ])
                    }
                }
            }
            .sheet(isPresented: $isShowingCreateFolderView) {
                CreateFolderView()
            }
        }
        .searchable(text: $searchText, isPresented: $searchIsActive,  prompt: "Search")
    }
}

#Preview {
    ContentView()
}
