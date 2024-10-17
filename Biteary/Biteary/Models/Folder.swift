//
//  Folder.swift
//  Biteary
//
//  Created by Rodrigo Llaguno on 11/10/24.
//

import Foundation
import SwiftData
import SwiftUI

@Model
class Folder: Identifiable {
    var id: UUID = UUID()
    var name: String
    var startDate: Date
    var endDate: Date
    var color: String
    var foods: [Food]
    var dateCreated: Date
    
    //Folder class initializer
    init(id: UUID, name: String, startDate: Date, endDate: Date, color: String, foods: [Food], dateCreated: Date) {
        self.id = id
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.color = color
        self.foods = foods
        self.dateCreated = dateCreated
    }
    
    func getFolderColor() -> Color {
        switch color {
        case "blue":
            return .blueFolder
        case "red":
            return .redFolder
        case "purple":
            return .purpleFolder
        case "green":
            return .greenFolder
        case "yellow":
            return .yellowFolder
        case "gray":
            return .grayFolder
        default:
            return .orangeFolder
        }
    }
}
