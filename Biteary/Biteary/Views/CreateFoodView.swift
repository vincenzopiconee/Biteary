//
//  CreateFoodView.swift
//  Biteary
//
//  Created by Rodrigo Llaguno on 10/10/24.
//

import SwiftUI

struct CreateFoodView: View {
    
    
    @Environment(\.dismiss) var dismiss

    @State private var dishName: String = ""
    @State private var restaurantName: String = ""
    @State private var cityName: String = ""
    @State private var price: Double = 0.00
    @State private var rating: Int = 0
    @State private var notes: String = ""
    @State private var foodDate: Date = Date.now
    let currencyFormat = Locale.current.currency?.identifier ?? "EUR"
    
    
    var body: some View {
        
        NavigationStack {
            
            Button{
                
            } label: {
                AddImage()
            }
            .padding()
                
            
            Form {
                Section("Dish Name") {
                    TextField("Type the dish name", text: $dishName)
                }
                
                Section("Restaurant Name") {
                    TextField("Type the restaurant name", text: $restaurantName)
                }
                
                //data
                Section("Date") {
                    HStack {
                        DatePicker("Insert the date", selection: $foodDate, displayedComponents: .date)
                            .foregroundStyle(.grayFolderBack)

                    }
                    
                    
                }
                
                
                Section("City") {
                    TextField("Type the city where you eat this", text: $cityName)
                }
                
                Section("Price") {
                    TextField("Type", value: $price, format: .currency(code: currencyFormat))
                        .keyboardType(.decimalPad)
                }
                
                Section ("Rating") {
                    Rating(rating: $rating)
                }
                
                Section("Notes") {
                    TextEditor(text: $notes)
                }
            }
            .navigationTitle("Add Dish")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing){
                    Button {
                        //save folder
                    } label: {
                        Text("Save")
                    }
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
    CreateFoodView()
}


