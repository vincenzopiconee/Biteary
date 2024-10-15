//
//  ColorPickerView.swift
//  Biteary
//
//  Created by Mikhail Kostenko on 15/10/24.
//

import SwiftUI

struct ColorPickerView: View {
    @State var colors: [Color] = [.red, .blue, .green]
    @Binding var selectedColor: Color
    
    var body: some View {
        HStack {
            ForEach(colors, id: \.self) { color in
                Button {
                    selectedColor = color
                } label: {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(color.gradient.opacity(selectedColor == color ? 1 : 0.5))
                        .shadow(radius: 5)
                }
                .buttonStyle(BorderlessButtonStyle())
                
            }
        }
    }
}
