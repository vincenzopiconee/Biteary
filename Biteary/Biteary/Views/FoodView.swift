//
//  FoodView.swift
//  Biteary
//
//  Created by Rodrigo Llaguno on 10/10/24.
//

import SwiftUI

struct FoodView: View {
    
    var food: Food
    var folder: Folder
    
    var body: some View {
        NavigationStack {
            
            if let firstImage = food.getFirstImage() {
                Image(uiImage: firstImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .padding()
            }
                
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
                        EditFoodView(food: food, folder: folder)
                    } label: {
                        Text("Edit")
                    }
                }
            }
        }

    }
}

#Preview {
    FoodView(food: Food(dishName: "Pizza", restaurantName: "Michele",city: "Napoli", price: 7.5, rating: 4, notes: "I really liked the sauce"), folder: Folder(id: UUID(), name: "Napoli", startDate: Date.now, endDate: Date.now, color: "orange", foods: [Food(dishName: "Pizza", restaurantName: "Michele",city: "Napoli", price: 7.5, rating: 4, notes: "I really liked the sauce")]))
}

// dname rname date city price rating notes
