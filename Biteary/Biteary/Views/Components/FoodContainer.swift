//
//  FoodContainer.swift
//  Biteary
//
//  Created by Rodrigo Llaguno on 11/10/24.
//

import SwiftUI

struct FoodContainer: View {
    
    var food: Food
    
    var body: some View {
        ZStack(alignment: .top) {
            // Background image, clipped to the rounded rectangle
            Image("Pizza")
                .resizable()
                .scaledToFill()
                .frame(width: 110, height: 150)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .padding(.top, 5)
                .clipped()

            Rectangle()
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .frame(width: 120, height: 160)
                .foregroundStyle(.grayFolderBack)
                .opacity(0.4)

            Text(food.dishName)
                .foregroundStyle(.white)
                .font(.system(size: 14))
                .fontWeight(.bold)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(width: 120, height: 160)
    }


}

#Preview {
    FoodContainer(food: Food(dishName: "Pizza Frita"))
}
