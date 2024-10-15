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
                        FolderButton(color: folder.color, title: folder.name, startDate: folder.startDate, endDate: folder.endDate, image: folder.foods.first?.getFirstImage())
                            .scrollTransition { content, phase in
                                content
//                                    .opacity(phase.isIdentity ? 1 : 0.5) // Apply opacity animation
                                    .scaleEffect(phase.isIdentity ? 1 : 0.7)
                            }
                    }
                }
            }
        }
//        .contentMargins(-10, for: .scrollContent) // Add padding
                .scrollTargetBehavior(.viewAligned)
    }
    init(sort: [SortDescriptor<Folder>]) {
            _folders = Query(sort: sort)
        }
}

#Preview {
    FolderListView(sort: [SortDescriptor(\Folder.name)])
}
