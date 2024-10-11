//
//  FolderColorPicker.swift
//  Biteary
//
//  Created by Rodrigo Llaguno on 10/10/24.
//

import SwiftUI

struct FolderColorPicker: View {
    
    var color: Color
    
    var body: some View {
        Rectangle()
            .foregroundStyle(color)
            .frame(width: 300, height: 15)
            .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}

#Preview {
    FolderColorPicker(color: .orangeFolder)
}
