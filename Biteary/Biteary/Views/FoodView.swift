//
//  FoodView.swift
//  Biteary
//
//  Created by Rodrigo Llaguno on 10/10/24.
//

import SwiftUI

struct FoodView: View {
    
    var food: Food
    
    var body: some View {
        NavigationStack {
            
            Button{
                
            } label: {
                AddImage()
            }
            .padding()
                
            Form {
                Section("Dish Name") {
                    Text(food.dishName)
                }
                
                Section("Restaurant Name") {
                        Text(food.restaurantName)
                }
                Section("Date") {
                    Text(String(describing: food.date.formatted(date: .numeric, time: .omitted)))
                }
                
                Section("City") {
                    Text(food.city)
                }

                Section("Price") {
                    Text("\(String(food.price)) €")
                }
                
                Section("Rating") {
                    Rating(rating: .constant(food.rating))
                }
                
                Section("Notes") {
                    Text(food.notes)
                }
            }
            .navigationTitle(food.dishName)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing){
                    NavigationLink {
                        EditFoodView(food: food)
                    } label: {
                        Text("Edit")
                    }
                }
            }
        }

    }
}

#Preview {
    FoodView(food: Food(dishName: "Pizza", restaurantName: "Michele",city: "Napoli", price: 7.5, rating: 4, notes: "I really liked the sauce"))
}

// dname rname date city price rating notes
