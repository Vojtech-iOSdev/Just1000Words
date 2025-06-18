//
//  FirebaseFlashcardRepository.swift
//  Just1000Words
//
//  Created by Vojtěch Kalivoda on 6/18/25.
//

import Foundation
import FirebaseFirestore

class FirebaseFlashcardRepository: FlashcardRepositoryProtocol {
    private let db = Firestore.firestore()

    func loadDeck(for language: Language, completion: @escaping (Result<[Flashcard], Error>) -> Void) {
        db.collection("decks").document(language.rawValue.lowercased()).getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = snapshot?.data(),
                  let flashcardDicts = data["flashcards"] as? [[String: Any]] else {
                completion(.failure(NSError(domain: "ParsingError", code: -1, userInfo: ["reason": "flashcards missing or malformed"])))
                return
            }

            let flashcards: [Flashcard] = flashcardDicts.compactMap { dict in
                guard let word = dict["word"] as? String,
                      let translation = dict["translation"] as? String else {
                    return nil
                }
                print("debug word \(word) missing")
                print("debug translation \(translation) missing")
                return Flashcard(id: UUID(), word: word, translation: translation)
            }
            
            print("debug\(flashcardDicts)")
            completion(.success(flashcards))
        }
    }
}
