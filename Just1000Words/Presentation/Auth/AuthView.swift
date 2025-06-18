//
//  AuthView.swift
//  Just1000Words
//
//  Created by Vojtěch Kalivoda on 6/18/25.
//


import SwiftUI

struct AuthView: View {
    @ObservedObject var authVM: AuthViewModel

    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var isRegistering = false

    var body: some View {
        VStack(spacing: 20) {
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            if isRegistering {
                TextField("Name", text: $name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }

            Button(isRegistering ? "Register" : "Login") {
                if isRegistering {
                    authVM.register(email: email, password: password, name: name)
                } else {
                    authVM.login(email: email, password: password)
                }
            }

            Button(isRegistering ? "Already have an account?" : "Create account") {
                isRegistering.toggle()
            }

            if let error = authVM.errorMessage {
                Text(error).foregroundColor(.red).font(.caption)
            }
        }
        .padding()
    }
}
