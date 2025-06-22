//
//  AppView.swift
//  Just1000Words
//
//  Created by Vojtěch Kalivoda on 6/18/25.
//

import SwiftUI

struct AppView: View {
    @StateObject var authVM = AuthViewModel()

    var body: some View {
        Group {
            if authVM.isLoggedIn {
                FlashcardView(authVM: authVM) // your existing main view
            } else {
                AuthView(authVM: authVM)
            }
        }
    }
}
