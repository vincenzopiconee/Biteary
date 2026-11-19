//
//  FoodContainer.swift
//  Biteary
//
//  Created by Rodrigo Llaguno on 11/10/24.
//

import SwiftUI

struct FoodContainer: View {
    @Environment(\.displayScale) private var displayScale
    
    var food: Food
    var body: some View {
        ZStack(alignment: .top) {
            // Background image, clipped to the rounded rectangle
            Rectangle()
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .frame(width: 104, height: 138)
                .foregroundStyle(.grayFolderBack)
                .opacity(0.4)
            
            if let thumbnail = food.getThumbnail(pointSize: CGSize(width: 94, height: 128), scale: displayScale) {
                Image(uiImage: thumbnail)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 94, height: 128)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .padding(.top, 5)
                    .clipped()
            }

            Text(food.dishName)
                .foregroundStyle(.white)
                .font(.system(size: 13))
                .fontWeight(.bold)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(width: 104, height: 138)
    }


}

#Preview {
    FoodContainer(food: Food(dishName: "Pizza Frita"))
}
