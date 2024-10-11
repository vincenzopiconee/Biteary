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
    
    var testFolders: [FolderButton] = [
        FolderButton(folderColor: .orangeFolder, folderColorBack: .orangeFolderBack, title: "Napoli", startDate: .now, endDate: .now),
        FolderButton(folderColor: .blueFolder, folderColorBack: .blueFolderBack, title: "Roma", startDate: .now, endDate: .now),
        FolderButton(folderColor: .redFolder, folderColorBack: .redFolderBack, title: "Berlin")
    ]

    
    var body: some View {
        NavigationStack {
            VStack {
                
                ScrollView {
                    LazyVStack {
                        ForEach(testFolders, id: \.self.title) { folder in
                            FolderButton(folderColor: folder.folderColor, folderColorBack: folder.folderColorBack, title: folder.title, startDate: folder.startDate, endDate: folder.endDate)
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
