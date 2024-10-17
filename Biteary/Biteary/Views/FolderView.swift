//
//  FolderView.swift
//  Biteary
//
//  Created by Rodrigo Llaguno on 10/10/24.
//

import SwiftUI

struct FolderView: View {
    
    @State private var isShowingCreateFoodView: Bool = false
    
    @State private var showingAlert = false
    var folder: Folder
    let layout = [
        GridItem(.fixed(150)),
        GridItem(.fixed(150))
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Image("folderBackgroundPic")
                    .resizable()
                    .scaledToFill()
                    .colorMultiply(folder.getFolderColor())
                    .opacity(0.05)
                    .ignoresSafeArea()
                VStack {
                    if folder.foods.isEmpty {
                        WelcomeScreenView(type: "food")
                    } else {
                        ScrollView {
                            LazyVGrid(columns: layout, spacing: 30) {
                                ForEach(folder.foods) { food in
                                    NavigationLink {
                                        FoodView(food: food, folder: folder)
                                    } label: {
                                        FoodContainer(food: food)
                                            .scrollTransition { content, phase in
                                                content
                                                    .scaleEffect(phase.isIdentity ? 1 : 0.1)
                                            }
                                            .contextMenu {
                                                Button(action: {
                                                    showingAlert = true
                                                }) {
                                                    Label("Delete", systemImage: "trash")
                                                }
                                                
                                                NavigationLink {
                                                    EditFoodView(food: food, folder: folder)
                                                } label: {
                                                    HStack {
                                                        Text("Edit")
                                                        Image(systemName: "pencil")
                                                    }
                                                }

                                                
                                                Button(action: {
                                                    
                                                }) {
                                                    Label("Share", systemImage: "square.and.arrow.up")
                                                }
                                            }
                                            .alert("Delete Dish", isPresented: $showingAlert){
                                                Button("Delete", role: .destructive) {
                                                    folder.foods.removeAll(where: { $0.id == food.id })
                                                }
                                                Button("Cancel", role: .cancel) { }
                                            } message: {
                                                Text("Are you sure you want to delete this dish?")
                                            }
                                        
                                    }
                                }
                            }
                        }
                    }
                    
                    Spacer()
                    
                    Button {
                        isShowingCreateFoodView.toggle()
                    } label: {
                        AddButton()
                    }
                }
            }
        }
        .navigationTitle(folder.name)
        .sheet(isPresented: $isShowingCreateFoodView) {
            CreateFoodView(folder: folder)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing){
                NavigationLink {
                    EditFolderView(folder: folder)
                } label: {
                    Text("Edit")
                }
                
            }
        }
        
        
        
    }
}

#Preview {
    FolderView(folder: Folder(id: UUID(), name: "Napoli", startDate: Date.now, endDate: Date.now, color: "blue", foods: [Food(dishName: "Pizza")]))
}
