//
//  EditFolderView.swift
//  Biteary
//
//  Created by Rodrigo Llaguno on 10/10/24.
//

import SwiftUI

struct EditFolderView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    @Bindable var folder: Folder
    
    @State private var showingAlert = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Folder Name") {
                    TextField("Type your folder name", text: $folder.name)
                }
                
                Section("Folder Dates") {
                    DatePicker("Start Date", selection: $folder.startDate, displayedComponents: .date)
                        .foregroundStyle(.grayFolderBack)
                    
                    DatePicker("End Date", selection: $folder.endDate, displayedComponents: .date)
                        .foregroundStyle(.grayFolderBack)
                }
                
                Section("Folder Colour") {
                    Picker("Choose a Colour", selection: $folder.color) {
                        FolderColorPicker(color: .orangeFolder).tag("orange")
                        FolderColorPicker(color: .blueFolder).tag("blue")
                        FolderColorPicker(color: .redFolder).tag("red")
                        FolderColorPicker(color: .purpleFolder).tag("purple")
                        FolderColorPicker(color: .greenFolder).tag("green")
                        FolderColorPicker(color: .yellowFolder).tag("yellow")
                        FolderColorPicker(color: .grayFolder).tag("gray")
                    }
                    .pickerStyle(.inline)
                    .foregroundStyle(.grayFolderBack)
                }
                
                Section {
                    HStack {
                        Spacer()
                        
                        Button {
                            showingAlert.toggle()
                        } label: {
                            Text("Delete Folder")
                                .foregroundStyle(.red)
                        }
                        
                        Spacer()
                    }
                }
            }
            .navigationTitle("Edit Folder")
            .alert("Delete Folder", isPresented: $showingAlert){
                Button("Delete", role: .destructive) {
                    folder.foods.removeAll()
                    modelContext.delete(folder)
                    dismiss()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to delete this folder?")
            }
        }
    }
}

#Preview {
    EditFolderView(folder: Folder(id: UUID(), name: "Rome", startDate: Date.now, endDate: Date.now, color: "green", foods: [Food(dishName: "Pizza")]))
}
