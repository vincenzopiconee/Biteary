//
//  FolderButton.swift
//  Biteary
//
//  Created by Rodrigo Llaguno on 10/10/24.
//

import SwiftUI

struct FolderButton: View {
    
    var folderColor: Color
    var folderColorBack: Color
    var title: String
    var startDate: Date?
    var endDate: Date?
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Rectangle()
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .frame(width: 150, height: 172)
                .foregroundStyle(folderColorBack)
            
            Rectangle()
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .frame(width: 320, height: 160)
                .foregroundStyle(folderColor)
            
            Text(title)
                .foregroundStyle(.folderText)
                .font(.system(size: 25))
                .fontWeight(.semibold)
                .offset(x: 28, y: -108)
            
            if let startDate, let endDate{
                Text("\(String(describing: startDate.formatted(date: .numeric, time: .omitted))) - \(String(describing: endDate.formatted(date: .numeric, time: .omitted)))")
                    .foregroundStyle(.folderText)
                    .font(.system(size: 10))
                    .fontWeight(.semibold)
                    .offset(x: 28, y: -85)
            }
                
        }
    }
}

#Preview {
    FolderButton(folderColor: .orangeFolder, folderColorBack: .orangeFolderBack, title: "Napoli", startDate: .now, endDate: .now)
}
