//
//  CreateFolderView.swift
//  Biteary
//
//  Created by Rodrigo Llaguno on 10/10/24.
//

import SwiftUI

struct CreateFolderView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    
    @State private var folderName: String = ""
    @State private var folderStartDate: Date = Date.now
    @State private var folderEndDate: Date = Date.now
    @State private var folderColor: Color = Color.orangeFolder

    
    var body: some View {
        NavigationStack {
            Form {
                Section("Folder Name") {
                    TextField("Type your folder name", text: $folderName)
                        .submitLabel(.done)
                }
                
                Section("Folder Dates") {
                    DatePicker("Start Date", selection: $folderStartDate, displayedComponents: .date)
                        .foregroundStyle(.grayFolderBack)
                    
                    DatePicker("End Date", selection: $folderEndDate, displayedComponents: .date)
                        .foregroundStyle(.grayFolderBack)
                }
                
                Section("Folder Colour") {
                    Picker("Choose a Colour", selection: $folderColor) {  // folderColor is of type Color
                        FolderColorPicker(color: .orangeFolder).tag(Color.orangeFolder)
                        FolderColorPicker(color: .blueFolder).tag(Color.blueFolder)
                        FolderColorPicker(color: .redFolder).tag(Color.redFolder)
                        FolderColorPicker(color: .purpleFolder).tag(Color.purpleFolder)
                        FolderColorPicker(color: .greenFolder).tag(Color.greenFolder)
                        FolderColorPicker(color: .yellowFolder).tag(Color.yellowFolder)
                        FolderColorPicker(color: .grayFolder).tag(Color.grayFolder)
                    }
                    .pickerStyle(.inline)
                    .foregroundStyle(.grayFolderBack)
                }
            }
            .navigationTitle("Create Folder")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing){
                    Button {
                        let folderColorValue = getColor(for: folderColor)
                        let newFolder = Folder(id: UUID(), name: folderName, startDate: folderStartDate, endDate: folderEndDate, color: folderColorValue, foods: [])
                        modelContext.insert(newFolder)
                        dismiss()
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
    
    func getColor(for colorString: Color) -> String {
        switch colorString {
        case .orangeFolder:
            return "orange"
        case .blueFolder:
            return "blue"
        case .redFolder:
            return "red"
        case .purpleFolder:
            return "purple"
        case .greenFolder:
            return "green"
        case .yellowFolder:
            return "yellow"
        case .grayFolder:
            return "gray"
        default:
            return "orange"
        }
    }
}

#Preview {
    CreateFolderView()
}
