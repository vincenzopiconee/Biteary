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
    @State private var folderColor: Color = Color.purpleFolder
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Folder Name") {
                    TextField("Type your folder name", text: $folderName)
                        .submitLabel(.done)
                }
                
                Section("Folder Dates") {
                    DatePicker("Start Date", selection: $folderStartDate, in:...folderEndDate, displayedComponents: .date)
                        .foregroundStyle(.grayFolderBack)
                    
                    DatePicker("End Date", selection: $folderEndDate, in: folderStartDate..., displayedComponents: .date)
                        .foregroundStyle(.grayFolderBack)
                }
                
                Section("Folder Colour") {
                    ColorPickerView(colors: [.orangeFolder, .blueFolder, .redFolder, .purpleFolder, .greenFolder, .yellowFolder, .grayFolder], selectedColor: $folderColor)
                }
                
            }
            .navigationTitle("Create Folder")
            .scrollDismissesKeyboard(.immediately)
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
                    .disabled(folderName.isEmpty)
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
