//
//  AuthViewModel.swift
//  Just1000Words
//
//  Created by Vojtěch Kalivoda on 6/18/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class AuthViewModel: ObservableObject {
    @Published var isLoggedIn = false
    @Published var errorMessage: String?
    
    private let auth = Auth.auth()
    private let db = Firestore.firestore()

    init() {
        self.isLoggedIn = auth.currentUser != nil
    }

    func register(email: String, password: String, name: String) {
        auth.createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                DispatchQueue.main.async { self.errorMessage = error.localizedDescription }
                return
            }
            guard let uid = result?.user.uid else { return }
            self.db.collection("users").document(uid).setData([
                "name": name,
                "languages": []
            ]) { err in
                DispatchQueue.main.async {
                    if err == nil { self.isLoggedIn = true }
                    else { self.errorMessage = err!.localizedDescription }
                }
            }
        }
    }

    func login(email: String, password: String) {
        auth.signIn(withEmail: email, password: password) { _, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = error.localizedDescription
                } else {
                    self.isLoggedIn = true
                }
            }
        }
    }

    func logout() {
        try? auth.signOut()
        self.isLoggedIn = false
    }

    func currentUserId() -> String? {
        return auth.currentUser?.uid
    }
}
