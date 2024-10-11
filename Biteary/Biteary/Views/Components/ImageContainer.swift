//
//  ImageContainer.swift
//  Biteary
//
//  Created by Rodrigo Llaguno on 11/10/24.
//

import SwiftUI

struct ImageContainer: View {
    
    var image: UIImage
    
    var body: some View {
        ZStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .frame(width: 200, height: 200)
        }
    }
}

#Preview {
    ImageContainer(image: UIImage(systemName: "photo")!)
}
