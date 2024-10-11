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
        ZStack(alignment: .topLeading) {
            Rectangle()
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .frame(width: 120, height: 160)
                .foregroundStyle(.grayFolderBack)
                .opacity(0.4)
            
            Text(food.dishName)
                .foregroundStyle(.white)
                .font(.system(size: 14))
                .fontWeight(.semibold)
                .padding()
            
            
        }
        .frame(width: 120, height: 160)
    }
}

#Preview {
    FoodContainer(food: Food(dishName: "Pizza Frita"))
}
