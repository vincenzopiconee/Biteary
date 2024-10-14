//
//  EditFoodView.swift
//  Biteary
//
//  Created by Rodrigo Llaguno on 10/10/24.
//

import SwiftUI

struct EditFoodView: View {
    @Environment(\.dismiss) var dismiss
    
    @Bindable var food: Food
    @State private var showingAlert = false
    
    let currencyFormat = Locale.current.currency?.identifier ?? "EUR"
    
    var body: some View {
        
        NavigationStack {
            
            Button{
                //Action to add image
            } label: {
                AddImage()
            }
            .padding()
            
            Form {
                Section("Dish Name") {
                    TextField("Type the dish name", text: $food.dishName)
                }
                
                Section("Restaurant Name") {
                    TextField("Type the restaurant name", text: $food.restaurantName)
                }
                
                Section("Date") {
                    HStack {
                        DatePicker("Insert the date", selection: $food.date, displayedComponents: .date)
                            .foregroundStyle(.grayFolderBack)
                    }
                }
                
                Section("City") {
                    TextField("Type the city where you eat this", text: $food.city)
                }
                
                Section("Price") {
                    TextField("Type", value: $food.price, format: .currency(code: currencyFormat))
                        .keyboardType(.decimalPad)
                }
                
                Section ("Rating") {
                    Rating(rating: $food.rating)
                }
                
                Section("Notes") {
                    TextEditor(text: $food.notes)
                }
                
                Section {
                    HStack {
                        Spacer()
                        
                        Button {
                            showingAlert.toggle()
                        } label: {
                            Text("Delete Dish")
                                .foregroundStyle(.red)
                        }
                        
                        Spacer()
                    }
                }
            }
            .navigationTitle("Edit Dish")
            .alert("Delete Dish", isPresented: $showingAlert){
                Button("Delete", role: .destructive) {
                    //Delete Dish action
                    dismiss()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to delete this dish?")
            }
        }
    }
}

#Preview {
    EditFoodView(food: Food(dishName: "Pizza Frita"))
}
