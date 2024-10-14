//
//  CreateFoodView.swift
//  Biteary
//
//  Created by Rodrigo Llaguno on 10/10/24.
//

import SwiftUI

struct CreateFoodView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    var folder: Folder

    @State private var dishName: String = ""
    @State private var restaurantName: String = ""
    @State private var cityName: String = ""
    @State private var price: Double = 0.0
    @State private var rating: Int = 0
    @State private var notes: String = ""
    @State private var foodDate: Date = Date.now
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
                    TextField("Type the dish name", text: $dishName)
                        .submitLabel(.done)
                }
                
                Section("Restaurant Name") {
                    TextField("Type the restaurant name", text: $restaurantName)
                        .submitLabel(.done)
                }
                
                Section("Date") {
                    HStack {
                        DatePicker("Insert the date", selection: $foodDate, displayedComponents: .date)
                            .foregroundStyle(.grayFolderBack)
                    }
                }
                
                Section("City") {
                    TextField("Type the city where you eat this", text: $cityName)
                        .submitLabel(.done)
                }
                
                Section("Price") {
                    TextField("Type", value: $price, format: .currency(code: currencyFormat))
                        .keyboardType(.decimalPad)
                        .submitLabel(.done)
                }
                
                Section ("Rating") {
                    Rating(rating: $rating)
                }
                
                Section("Notes") {
                    TextEditor(text: $notes)
                        .submitLabel(.done)
                }
            }
            .navigationTitle("Add Dish")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing){
                    Button {
                        let newFood = Food(dishName: dishName, restaurantName: restaurantName, city: cityName, price: price, rating: rating, notes: notes, date: foodDate, imageData: [])
                        folder.foods.append(newFood)
                        dismiss()
                    } label: {
                        Text("Save")
                    }
                    .disabled(dishName.isEmpty || restaurantName.isEmpty || cityName.isEmpty || price.isZero)
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                    }
                }
            }
        }
    }
}

#Preview {
    CreateFoodView(folder: Folder(id: UUID(), name: "Pizza", startDate: Date.now, endDate: Date.now, color: "orange", foods: []))
}


