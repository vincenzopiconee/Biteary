//
//  AddButton.swift
//  Biteary
//
//  Created by Rodrigo Llaguno on 10/10/24.
//

import SwiftUI

struct AddButton: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(.orangeFolder)
                .frame(width: 80, height: 80)
            
            Image(systemName: "plus")
                .foregroundStyle(.white)
                .font(.title.bold())
        }
    }
}

#Preview {
    AddButton()
}
