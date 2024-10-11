//
//  ContentView.swift
//  Biteary
//
//  Created by Rodrigo Llaguno on 10/10/24.
//

import SwiftUI

struct ContentView: View {
    @State private var searchText: String = ""
    @State private var isShowingCreateFolderView: Bool = false
    
    @State private var sortOrder = [
        SortDescriptor(\Folder.name),
        SortDescriptor(\Folder.startDate)
    ]
    
    var testFolders: [Folder] = [
        Folder(id: UUID(), name: "Napoli", startDate: Date.now, endDate: Date.now, color: "orange", foods: [Food(dishName: "Pizza")]),
        Folder(id: UUID(), name: "Roma", startDate: Date.now, endDate: Date.now, color: "red", foods: [Food(dishName: "Pizza")]),
        Folder(id: UUID(), name: "Berlin", startDate: Date.now, endDate: Date.now, color: "green", foods: [Food(dishName: "Pizza")])
    ]

    
    var body: some View {
        NavigationStack {
            VStack {
                
                ScrollView {
                    LazyVStack {
                        ForEach(testFolders, id: \.self.name) { folder in
                            NavigationLink {
                                FolderView(folder: folder)
                            } label: {
                                FolderButton(color: folder.color, title: folder.name, startDate: folder.startDate, endDate: folder.endDate)
                            }
                        }
                    }
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
                        Text("Sort by Name")
                            .tag([
                                SortDescriptor(\Folder.name),
                                SortDescriptor(\Folder.startDate)
                            ])
            
                        Text("Sort by Start Date")
                            .tag([
                                SortDescriptor(\Folder.startDate),
                                SortDescriptor(\Folder.name)
                            ])
                    }
                }
            }
            .sheet(isPresented: $isShowingCreateFolderView) {
                CreateFolderView()
            }
            
        }
    }
}

#Preview {
    ContentView()
}
