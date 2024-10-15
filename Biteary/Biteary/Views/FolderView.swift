//
//  FolderView.swift
//  Biteary
//
//  Created by Rodrigo Llaguno on 10/10/24.
//

import SwiftUI

struct FolderView: View {
        
    @State private var isShowingCreateFoodView: Bool = false
    
    var folder: Folder
    let layout = [
        GridItem(.fixed(150)),
        GridItem(.fixed(150))
    ]
    /*
    var testFood: [Food] = [
        Food(dishName: "Pizza Frita"),
        Food(dishName: "Pasta"),
        Food(dishName: "Tacos")
    ]
     */
    
    var body: some View {
        NavigationStack {
            VStack {
                
                ScrollView {
                    LazyVGrid(columns: layout, spacing: 30) {
                        ForEach(folder.foods) { food in
                            NavigationLink {
                                FoodView(food: food, folder: folder)
                            } label: {
                                FoodContainer(food: food)
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
            .padding()
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
}

#Preview {
    FolderView(folder: Folder(id: UUID(), name: "Napoli", startDate: Date.now, endDate: Date.now, color: "blue", foods: [Food(dishName: "Pizza")]))
}
