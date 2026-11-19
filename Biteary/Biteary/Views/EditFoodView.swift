//
//  EditFoodView.swift
//  Biteary
//
//  Created by Rodrigo Llaguno on 10/10/24.
//

import SwiftUI

struct EditFoodView: View {
    @Environment(\.dismiss) var dismiss
    
    @Environment(\.presentationMode) var presentationMode
    
    @Bindable var food: Food
    @Bindable var folder: Folder

    let currencyFormat = Locale.current.currency?.identifier ?? "EUR"
    
    //Image var
    @State private var showImagePicker: Bool = false
    @State private var showPhotosPicker: Bool = false
    @State private var showActionSheet = false
    @State private var image: UIImage?
    
    
    var body: some View {
        
        NavigationStack {
            
            Button{
                showActionSheet.toggle()
            } label: {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .padding()
                        .contextMenu {
                            Button("Take Picture with Camera") {
                                showImagePicker.toggle()
                            }
                            
                            Button("Choose a Picture from Gallery") {
                                showPhotosPicker.toggle()
                            }
                        }
                    
                } else if let image = food.getFirstImage() {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .padding()
                        .contextMenu {
                            Button("Take Picture with Camera") {
                                showImagePicker.toggle()
                            }
                            
                            Button("Choose a Picture from Gallery") {
                                showPhotosPicker.toggle()
                            }
                        }
                } else {
                    AddImage()
                        .contextMenu {
                            Button("Take Picture with Camera") {
                                showImagePicker.toggle()
                            }
                            
                            Button("Choose a Picture from Gallery") {
                                showPhotosPicker.toggle()
                            }
                        }
                }
            }
            .actionSheet(isPresented: $showActionSheet) {
                ActionSheet(title: Text("Choose method to upload image"),
                            buttons: [
                                .cancel(),
                                .default(
                                    Text("Take Picture with Camera"),
                                    action: {
                                        showImagePicker.toggle()
                                    }
                                ),
                                .default(
                                    Text("Choose a Picture from Gallery"),
                                    action: {
                                        showPhotosPicker.toggle()
                                    }
                                )
                            ]
                )
            }
            .onChange(of: image) { oldImage, newImage in
                food.deleteImage(at: 0)
                if let newImage = image {
                    food.addImage(newImage)
                }
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
                
            }
            .fullScreenCover(isPresented: $showImagePicker) {
                ImagePicker(image: self.$image, sourceType: .camera)
                    .edgesIgnoringSafeArea(.all)
            }
            
            .fullScreenCover(isPresented: $showPhotosPicker) {
                ImagePicker(image: self.$image, sourceType: .photoLibrary)
                    .edgesIgnoringSafeArea(.bottom)
                    
            }
            .navigationTitle("Edit Dish")
            .scrollDismissesKeyboard(.immediately)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Save")
                        }
                    }
                }
            }
             
        }
    }
}

#Preview {
    EditFoodView(food: Food(dishName: "Pizza", restaurantName: "Michele",city: "Napoli", price: 7.5, rating: 4, notes: "I really liked the sauce"), folder: Folder(id: UUID(), name: "Napoli", startDate: Date.now, endDate: Date.now, color: "orange", foods: [Food(dishName: "Pizza", restaurantName: "Michele",city: "Napoli", price: 7.5, rating: 4, notes: "I really liked the sauce")], dateCreated: Date.now))
}
