//
//  FirebaseAuthService.swift
//  Just1000Words
//
//  Created by Vojtěch Kalivoda on 6/18/25.
//


import FirebaseAuth
import FirebaseFirestore

class FirebaseAuthService {
    static let shared = FirebaseAuthService()
    private init() {}

    private let auth = Auth.auth()
    private let db = Firestore.firestore()

    func registerUser(email: String, password: String, name: String, completion: @escaping (Result<Void, Error>) -> Void) {
        auth.createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let uid = result?.user.uid else {
                completion(.failure(NSError(domain: "Auth", code: -1)))
                return
            }

            let userDoc = [
                "name": name,
                "languages": [] // empty, user will select later
            ]

            self.db.collection("users").document(uid).setData(userDoc) { err in
                if let err = err {
                    completion(.failure(err))
                } else {
                    completion(.success(()))
                }
            }
        }
    }

    func loginUser(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        auth.signIn(withEmail: email, password: password) { _, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    func currentUserId() -> String? {
        return auth.currentUser?.uid
    }

    func logout() {
        try? auth.signOut()
    }
}
