//
//  AddImage.swift
//  Biteary
//
//  Created by Vincenzo Picone on 11/10/24.
//



import SwiftUI

struct AddImage: View {
    var body: some View {
        ZStack {
            Rectangle()
                .fill(.grayForm)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .frame(width: 200, height: 200)
            
            Image(systemName: "plus")
                .foregroundStyle(.white)
                .font(.system(size: 50).bold())
                           
        }
    }
}

#Preview {
    AddImage()
}
