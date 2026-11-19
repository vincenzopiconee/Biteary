//
//  FolderView.swift
//  Biteary
//
//  Created by Rodrigo Llaguno on 10/10/24.
//

import QuickLook
import SwiftUI

struct FolderView: View {
    
    @State private var isShowingCreateFoodView: Bool = false
    
    @State private var showingAlert = false
    @State private var foodToDelete: Food?
    @State private var previewPDFURL: URL?
    @State private var pdfErrorMessage: String?
    var folder: Folder
    let layout = [
        GridItem(.fixed(115)),
        GridItem(.fixed(115)),
        GridItem(.fixed(115))
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Image("folderBackgroundPic")
                    .resizable()
                    .scaledToFill()
                    .colorMultiply(folder.getFolderColor())
                    .opacity(0.05)
                    .ignoresSafeArea()
                VStack {
                    if folder.foods.isEmpty {
                        WelcomeScreenView(type: "food")
                    } else {
                        ScrollView {
                            LazyVGrid(columns: layout, spacing: 30) {
                                ForEach(folder.foods) { food in
                                    NavigationLink {
                                        FoodView(food: food, folder: folder)
                                    } label: {
                                        FoodContainer(food: food)
                                            .scrollTransition { content, phase in
                                                content
                                                    .scaleEffect(phase.isIdentity ? 1 : 0.1)
                                            }
                                            .contextMenu {
                                                Button(action: {
                                                    foodToDelete = food
                                                    showingAlert = true
                                                }) {
                                                    Label("Delete", systemImage: "trash")
                                                }
                                                
                                                NavigationLink {
                                                    EditFoodView(food: food, folder: folder)
                                                } label: {
                                                    HStack {
                                                        Text("Edit")
                                                        Image(systemName: "pencil")
                                                    }
                                                }
                                            }
                                        
                                    }
                                }
                            }
                        }
                    }
                    
                    Spacer()
                    
                    Button {
                        isShowingCreateFoodView.toggle()
                    } label: {
                        AddButton()
                    }
                }
            }
        }
        .navigationTitle(folder.name)
        .alert("Delete Dish", isPresented: $showingAlert, presenting: foodToDelete) { food in
            Button("Delete", role: .destructive) {
                folder.foods.removeAll(where: { $0.id == food.id })
            }
            Button("Cancel", role: .cancel) { }
        } message: { _ in
            Text("Are you sure you want to delete this dish?")
        }
        .sheet(isPresented: $isShowingCreateFoodView) {
            CreateFoodView(folder: folder)
        }
        .quickLookPreview($previewPDFURL)
        .alert("Unable to Preview Trip Guide", isPresented: Binding(
            get: { pdfErrorMessage != nil },
            set: { if !$0 { pdfErrorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {
                pdfErrorMessage = nil
            }
        } message: {
            Text(pdfErrorMessage ?? "An unexpected error occurred while generating the PDF.")
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    generateTripGuidePDF()
                } label: {
                    Image(systemName: "doc.richtext")
                }
                .disabled(folder.foods.isEmpty)
                .accessibilityLabel("Preview Trip Guide PDF")
                .accessibilityHint("Generates an A4 culinary guide PDF for this trip and opens it in Quick Look.")
                
                NavigationLink {
                    EditFolderView(folder: folder)
                } label: {
                    Text("Edit")
                }
            }
        }
    }
    
    private func generateTripGuidePDF() {
        do {
            previewPDFURL = try TripPDFRenderer.render(folder: folder)
        } catch {
            pdfErrorMessage = error.localizedDescription
        }
    }
}

#Preview {
    FolderView(folder: Folder(id: UUID(), name: "Napoli", startDate: Date.now, endDate: Date.now, color: "blue", foods: [Food(dishName: "Pizza"), Food(dishName: "Kebab"), Food(dishName: "Pallavolo")], dateCreated: Date.now))
}
