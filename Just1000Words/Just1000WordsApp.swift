//
//  Just1000WordsApp.swift
//  Just1000Words
//
//  Created by Vojtěch Kalivoda on 6/18/25.
//

import SwiftUI
import Firebase

@main
struct Just1000WordsApp: App {
    init() {
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            AppView()
        }
    }
}
