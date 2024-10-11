//
//  Food.swift
//  Biteary
//
//  Created by Rodrigo Llaguno on 11/10/24.
//

import Foundation
import SwiftData
import UIKit

@Model
class Food: Identifiable {
    var id: UUID = UUID()
    var dishName: String
    var restaurantName: String
    var city: String
    var price: Double
    var rating: Int
    var notes: String
    var date: Date
    var imageData: [Data]?
    
    //Food class initializer
    init(dishName: String, restaurantName: String = "", city: String = "", price: Double = 0.0, rating: Int = 0, notes: String = "", date: Date = Date.now, imageData: [Data]? = nil) {
        self.dishName = dishName
        self.restaurantName = restaurantName
        self.city = city
        self.price = price
        self.rating = rating
        self.notes = notes
        self.date = date
        self.imageData = imageData
    }
    
    // Method to add a UIImage as Data
    func addImage(_ image: UIImage) {
        let data = image.jpegData(compressionQuality: 0.8)
        if let data = data {
            if imageData == nil {
                imageData = [data]
            } else {
                imageData?.append(data)
            }
        }
    }
    
    // Method to delete an image by index
    func deleteImage(at index: Int) {
        guard let imageData = imageData, imageData.indices.contains(index) else {
            return
        }
        self.imageData?.remove(at: index)
    }
    
    // Method to retrieve images as an array of UIImage
    func getImages() -> [UIImage]? {
        return imageData?.compactMap { UIImage(data: $0) }
    }
}
