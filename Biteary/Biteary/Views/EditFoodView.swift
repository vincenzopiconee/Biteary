//
//  EditFoodView.swift
//  Biteary
//
//  Created by Rodrigo Llaguno on 10/10/24.
//

import PhotosUI
import SwiftUI

struct EditFoodView: View {
    @Environment(\.dismiss) var dismiss
    
    @Environment(\.presentationMode) var presentationMode
    
    @Bindable var food: Food
    @Bindable var folder: Folder

    @State private var showingAlert = false
    
    let currencyFormat = Locale.current.currency?.identifier ?? "EUR"
    
    //Image var
    @State private var showImagePicker: Bool = false
    @State private var pickerItem: PhotosPickerItem?
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
            .sheet(isPresented: $showImagePicker) {
                ImagePickerView(image: self.$image, isShown: self.$showImagePicker)
            }
            .sheet(isPresented: $showPhotosPicker) {
                PhotosPicker("Select an image", selection: $pickerItem, matching: .images)
            }
            .onChange(of: pickerItem) { oldItem, newItem in
                Task {
                    showPhotosPicker.toggle()

                    if let newItem = newItem,
                       let data = try? await newItem.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        image = uiImage
                    }
                }
            }
            .navigationTitle("Edit Dish")
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
            .alert("Delete Dish", isPresented: $showingAlert){
                Button("Delete", role: .destructive) {
                    folder.foods.removeAll(where: { $0.id == food.id })
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
    EditFoodView(food: Food(dishName: "Pizza", restaurantName: "Michele",city: "Napoli", price: 7.5, rating: 4, notes: "I really liked the sauce"), folder: Folder(id: UUID(), name: "Napoli", startDate: Date.now, endDate: Date.now, color: "orange", foods: [Food(dishName: "Pizza", restaurantName: "Michele",city: "Napoli", price: 7.5, rating: 4, notes: "I really liked the sauce")]))
}
