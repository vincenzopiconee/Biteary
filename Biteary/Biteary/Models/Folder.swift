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
    var startDate: Date?
    var endDate: Date?
    var color: String
    var foods: [Food]
    
    //Folder class initializer
    init(id: UUID, name: String, startDate: Date? = nil, endDate: Date? = nil, color: String, foods: [Food]) {
        self.id = id
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.color = color
        self.foods = foods
    }
}
