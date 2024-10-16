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

struct ColorPickerStrView: View {
    @State var colors: [Color] = [.red, .blue, .green]
    @Binding var selectedColor: String
    
    var body: some View {
        HStack {
            ForEach(colors, id: \.self) { color in
                Button {
                    selectedColor = switch color {
                    case .blueFolder:
                        "blue"
                    case .redFolder:
                        "red"
                    case .purpleFolder:
                        "purple"
                    case .greenFolder:
                        "green"
                    case .yellowFolder:
                        "yellow"
                    case .grayFolder:
                        "gray"
                    default:
                        "orange"
                    }
                } label: {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(color.gradient.opacity(selectedColor == getColor(for: color) ? 1 : 0.5))
                        .shadow(radius: 5)
                }
                .buttonStyle(BorderlessButtonStyle())
                
            }
        }
    }
    
    func getColor(for colorString: Color) -> String {
        switch colorString {
        case .orangeFolder:
            return "orange"
        case .blueFolder:
            return "blue"
        case .redFolder:
            return "red"
        case .purpleFolder:
            return "purple"
        case .greenFolder:
            return "green"
        case .yellowFolder:
            return "yellow"
        case .grayFolder:
            return "gray"
        default:
            return "orange"
        }
    }
}
