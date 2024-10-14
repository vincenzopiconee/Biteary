//
//  FolderListView.swift
//  Biteary
//
//  Created by Mikhail Kostenko on 14/10/24.
//

import SwiftData
import SwiftUI

struct FolderListView: View {
    @Environment(\.modelContext) var modelContext
    @Query var folders: [Folder]
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(folders) { folder in
                    NavigationLink {
                        FolderView(folder: folder)
                    } label: {
                        FolderButton(color: folder.color, title: folder.name, startDate: folder.startDate, endDate: folder.endDate)
                    }
                }
            }
        }
    }
    init(sort: [SortDescriptor<Folder>]) {
            _folders = Query(sort: sort)
        }
}

#Preview {
    FolderListView(sort: [SortDescriptor(\Folder.name)])
}
