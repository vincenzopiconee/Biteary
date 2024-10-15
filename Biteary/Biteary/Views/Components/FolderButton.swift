//
//  FolderButton.swift
//  Biteary
//
//  Created by Rodrigo Llaguno on 10/10/24.
//

import SwiftUI

struct FolderButton: View {
    
    @State private var isOpened = false
    
    var color: String
    var title: String
    var startDate: Date?
    var endDate: Date?
    var folderColor: Color {
        if color == "orange" {
            return Color.orangeFolder
        } else if color == "red"{
            return Color.redFolder
        } else if color == "blue"{
            return Color.blueFolder
        } else if color == "green"{
            return Color.greenFolder
        } else if color == "yellow"{
            return Color.yellowFolder
        } else if color == "gray"{
            return Color.grayFolder
        } else if color == "purple"{
            return Color.purpleFolder
        }
        return Color.orangeFolder
    }
    var folderColorBack: Color {
        if color == "orange" {
            return Color.orangeFolderBack
        } else if color == "red"{
            return Color.redFolderBack
        } else if color == "blue"{
            return Color.blueFolderBack
        } else if color == "green"{
            return Color.greenFolderBack
        } else if color == "yellow"{
            return Color.yellowFolderBack
        } else if color == "gray"{
            return Color.grayFolderBack
        } else if color == "purple"{
            return Color.purpleFolderBack
        }
        return Color.orangeFolderBack
    }
    
    var image: UIImage?
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Rectangle()
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .frame(width: 150, height: 172)
                .foregroundStyle(folderColorBack.gradient)
            
            Rectangle()
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .frame(width: 320, height: 160)
                .foregroundStyle(folderColor.gradient)
            
            HStack {
                VStack(alignment: .leading) {
                    Text(title)
                        .foregroundStyle(.folderText)
                        .font(.system(size: 25))
                        .fontWeight(.semibold)
                        .padding([.leading, .trailing, .bottom], 10)
                        .minimumScaleFactor(0.01)
                    
                    if let startDate, let endDate{
                        Text("\(String(describing: startDate.formatted(date: .numeric, time: .omitted))) - \(String(describing: endDate.formatted(date: .numeric, time: .omitted)))")
                            .foregroundStyle(.folderText)
                            .font(.system(size: 10))
                            .fontWeight(.semibold)
                            .padding([.leading, .trailing], 10)
                    }
                    Spacer()
                }
                .frame(width: 150, height: 150)
                .padding(.trailing, 10)
                if image != nil {
                    Image(uiImage: image!)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 120)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: CGFloat(10)))
                        .shadow(radius: 8, x: 0, y: 10)
                        .padding(.leading, 20)
                }
                
            }
        }
        

    }
}

#Preview {
    FolderButton(color: "orange", title: "Napoli", startDate: .now, endDate: .now, image: UIImage(imageLiteralResourceName: "Pizza"))
}
