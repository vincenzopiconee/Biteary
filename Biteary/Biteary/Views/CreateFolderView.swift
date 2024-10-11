//
//  CreateFolderView.swift
//  Biteary
//
//  Created by Rodrigo Llaguno on 10/10/24.
//

import SwiftUI

struct CreateFolderView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var folderName: String = ""
    @State private var folderStartDate: Date = Date.now
    @State private var folderEndDate: Date = Date.now
    @State private var folderColor: Color = .orangeFolder

    
    var body: some View {
        NavigationStack {
            Form {
                Section("Folder Name") {
                    TextField("Type your folder name", text: $folderName)
                }
                
                Section("Folder Dates") {
                    DatePicker("Start Date", selection: $folderStartDate, displayedComponents: .date)
                        .foregroundStyle(.grayFolderBack)
                    
                    DatePicker("End Date", selection: $folderEndDate, displayedComponents: .date)
                        .foregroundStyle(.grayFolderBack)
                }
                
                Section("Folder Colour") {
                    Picker("Choose a Colour", selection: $folderColor) {
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
            }
            .navigationTitle("Create Folder")
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
    CreateFolderView()
}
