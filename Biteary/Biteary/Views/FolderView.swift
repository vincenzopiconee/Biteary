//
//  FolderView.swift
//  Biteary
//
//  Created by Rodrigo Llaguno on 10/10/24.
//

import SwiftUI

struct FolderView: View {
    
    var folder: Folder
    
    @State private var isShowingCreateFoodView: Bool = false

    
    
    var body: some View {
        NavigationStack {
            VStack {
                
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
                CreateFoodView()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing){
                    Button {
                        //Edit folder
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
