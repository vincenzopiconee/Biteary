//
//  FoodView.swift
//  Biteary
//
//  Created by Rodrigo Llaguno on 10/10/24.
//

import SwiftData
import SwiftUI

struct FoodView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.displayScale) private var displayScale
    
    var food: Food
    var folder: Folder
    let currencyFormat = Locale.current.currency?.identifier ?? "EUR"
    
    @State private var isShowingQuickLookEditor = false
    
    var body: some View {
        NavigationStack {
            
            if let displayImage = food.getThumbnail(pointSize: CGSize(width: 400, height: 400), scale: displayScale) ?? food.getFirstImage() {
                Button {
                    isShowingQuickLookEditor = true
                } label: {
                    Image(uiImage: displayImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .overlay(alignment: .bottomTrailing) {
                            Label("Preview & Markup", systemImage: "pencil.tip.crop.circle")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.primary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(.ultraThinMaterial, in: Capsule())
                                .padding(10)
                        }
                        .padding()
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Preview and mark up \(food.dishName.isEmpty ? "dish" : food.dishName) photo")
                .accessibilityHint("Opens the dish photo in Quick Look with native iOS Markup annotation tools.")
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
                    Text(food.price, format: .currency(code: currencyFormat))
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
                ToolbarItemGroup(placement: .topBarTrailing) {
                    if food.imageData?.first != nil {
                        Button {
                            isShowingQuickLookEditor = true
                        } label: {
                            Image(systemName: "pencil.tip.crop.circle")
                        }
                        .accessibilityLabel("Preview & Markup")
                        .accessibilityHint("Opens the dish photo in Quick Look to view or annotate with iOS Markup.")
                    }
                    
                    NavigationLink {
                        EditFoodView(food: food, folder: folder)
                    } label: {
                        Text("Edit")
                    }
                }
            }
            .fullScreenCover(isPresented: $isShowingQuickLookEditor) {
                if let photoData = food.imageData?.first {
                    QuickLookImageEditor(
                        imageData: photoData,
                        title: food.dishName.isEmpty ? "Dish Photo" : food.dishName
                    ) { updatedData in
                        persistUpdatedPhoto(updatedData)
                    }
                    .ignoresSafeArea()
                }
            }
        }

    }
    
    private func persistUpdatedPhoto(_ updatedData: Data) {
        if food.imageData == nil || food.imageData?.isEmpty == true {
            food.imageData = [updatedData]
        } else {
            food.imageData?[0] = updatedData
        }
        try? modelContext.save()
    }
}

#Preview {
    FoodView(food: Food(dishName: "Pizza", restaurantName: "Michele",city: "Napoli", price: 7.5, rating: 4, notes: "I really liked the sauce"), folder: Folder(id: UUID(), name: "Napoli", startDate: Date.now, endDate: Date.now, color: "orange", foods: [Food(dishName: "Pizza", restaurantName: "Michele",city: "Napoli", price: 7.5, rating: 4, notes: "I really liked the sauce")], dateCreated: Date.now))
}
