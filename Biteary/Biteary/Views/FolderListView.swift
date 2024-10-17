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
                    
                    let image = updatePreviewImage(folder)
                    
                    NavigationLink {
                        FolderView(folder: folder)
                    } label: {
                        FolderButton(color: folder.color, title: folder.name, startDate: folder.startDate, endDate: folder.endDate, image: image)
                            .scrollTransition { content, phase in
                                content
                                    .scaleEffect(phase.isIdentity ? 1 : 0.7)
                            }

                    }
                }
            }
        }
        .scrollTargetBehavior(.viewAligned)
    }
    init(sort: [SortDescriptor<Folder>], searchString: String) {
        _folders = Query(filter: #Predicate {
            if searchString.isEmpty {
                return true
            } else {
                return $0.name.localizedStandardContains(searchString)
            }
        },sort: sort)
    }
    
    func updatePreviewImage(_ folder: Folder) -> UIImage? {
        folder.foods.first?.getFirstImage()
    }
}

#Preview {
    FolderListView(sort: [SortDescriptor(\Folder.name)], searchString: "")
}
