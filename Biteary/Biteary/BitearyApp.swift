//
//  BitearyApp.swift
//  Biteary
//
//  Created by Rodrigo Llaguno on 10/10/24.
//

import SwiftData
import SwiftUI

@main
struct BitearyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Folder.self)
    }
}
