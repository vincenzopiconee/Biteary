//
//  WelcomeScreenView.swift
//  Biteary
//
//  Created by Rodrigo Llaguno on 16/10/24.
//

import SwiftUI

struct WelcomeScreenView: View {
    
    @State private var isWiggling = false
    var type: String
    
    var body: some View {
        ContentUnavailableView {
            Label(type == "folder" ? "No Folders Created" : "Save your first dish", systemImage: type == "folder" ? "fork.knife" : "carrot.fill")
                .foregroundStyle(.accent)
                .if(isWiggling) { view in
                    view.symbolEffect(.wiggle.clockwise.byLayer, options: .nonRepeating)
                }                .onTapGesture {
                    isWiggling.toggle()
                }
        } description: {
            Text(type == "folder" ? "Click on the + button to start saving your dishes!" : "Click on the + button to record a new dish!")
        }
    }
}

extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

#Preview {
    WelcomeScreenView(type: "food")
}
