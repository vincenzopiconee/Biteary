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
                    
                    DatePicker("End Date", selection: $folderEndDate, displayedComponents: .date)
                }
                
                Section("Folder Colour") {
                    Picker("Choose a Colour", selection: $folderColor) {
                        FolderColorPicker(color: .orangeFolder).tag(Color.orangeFolder)
                        FolderColorPicker(color: .blueFolder).tag(Color.blueFolder)
                        FolderColorPicker(color: .redFolder).tag(Color.redFolder)
                        FolderColorPicker(color: .purpleFolder).tag(Color.purpleFolder)
                        FolderColorPicker(color: .greenFolder).tag(Color.greenFolder)
                        FolderColorPicker(color: .yellowFolder).tag(Color.yellowFolder)
                        FolderColorPicker(color: .grayFolder).tag(Color.grayFolder)

                    }
                    .pickerStyle(.inline)
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
