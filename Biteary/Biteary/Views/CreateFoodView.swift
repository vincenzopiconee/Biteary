//
//  CreateFoodView.swift
//  Biteary
//
//  Created by Rodrigo Llaguno on 10/10/24.
//

import PhotosUI
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
    
    //Image var
    @State private var showImagePicker: Bool = false
    @State private var showPhotosPicker: Bool = false
    @State private var showActionSheet = false
    @State private var pickerItem: PhotosPickerItem?
    @State private var image: UIImage?
    
    
    var body: some View {
        
        NavigationStack {
            
            Button {
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
                } else {
                    VStack {
                        AddImage()
                            .padding()
                    }
                    .contextMenu {
                        Button("Take Picture with Camera") {
                            showImagePicker.toggle()
                        }

                        Button("Choose a Picture from Gallery") {
                            showPhotosPicker.toggle()
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
                }
            }
            
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
            .sheet(isPresented: $showImagePicker) {
                ImagePickerView(image: self.$image, isShown: self.$showImagePicker)
            }
            .sheet(isPresented: $showPhotosPicker) {
                PhotosPicker("Select an image", selection: $pickerItem, matching: .images)
            }
            .onChange(of: pickerItem) { oldItem, newItem in
                Task {
                    showPhotosPicker.toggle()
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        image = uiImage
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing){
                    Button {
                        let newFood = Food(dishName: dishName, restaurantName: restaurantName, city: cityName, price: price, rating: rating, notes: notes, date: foodDate, imageData: [])
                        if let image {
                            newFood.addImage(image)
                        }
                        folder.foods.append(newFood)
                        dismiss()
                    } label: {
                        Text("Save")
                    }
                    .disabled(dishName.isEmpty)
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


struct ImagePickerView: UIViewControllerRepresentable {
    
    @Binding var image: UIImage?
    @Binding var isShown: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: ImagePickerView

        init(parent: ImagePickerView) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.isShown = false
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isShown = false
        }
    }
}
