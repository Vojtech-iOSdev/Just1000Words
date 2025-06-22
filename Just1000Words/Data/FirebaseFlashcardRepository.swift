//
//  FirebaseFlashcardRepository.swift
//  Just1000Words
//
//  Created by Vojtěch Kalivoda on 6/18/25.
//

//import Foundation
//import FirebaseFirestore
//
//class FirebaseFlashcardRepository: FlashcardRepositoryProtocol {
//    private let db = Firestore.firestore()
//
//    func loadDeck(for language: Language, completion: @escaping (Result<[Flashcard], Error>) -> Void) {
//        db.collection("decks").document(language.rawValue.lowercased()).getDocument { snapshot, error in
//            if let error = error {
//                completion(.failure(error))
//                return
//            }
//
//            guard let data = snapshot?.data(),
//                  let flashcardDicts = data["flashcards"] as? [[String: Any]] else {
//                completion(.failure(NSError(domain: "ParsingError", code: -1, userInfo: ["reason": "flashcards missing or malformed"])))
//                return
//            }
//
//            let flashcards: [Flashcard] = flashcardDicts.compactMap { dict in
//                guard let id = dict["id"] as? String,
//                      let word = dict["word"] as? String,
//                      let translation = dict["translation"] as? String else {
//                    return nil
//                }
//                print("debug word \(word) missing")
//                print("debug translation \(translation) missing")
//                return Flashcard(id: id, word: word, translation: translation)
//            }
//            
//            print("debug\(flashcardDicts)")
//            completion(.success(flashcards))
//        }
//    }
//}



import Foundation
import FirebaseFirestore
import FirebaseAuth

class FirebaseFlashcardRepository: ObservableObject {
    private let db = Firestore.firestore()
    private let auth = Auth.auth()

    func fetchDeck(for language: String, completion: @escaping ([Flashcard]) -> Void) {
        print("debug: \(language)")
        let deckRef = db.collection("decks").document(language.lowercased())

        deckRef.getDocument { snapshot, error in
            guard let data = snapshot?.data(),
                  let cardDicts = data["flashcards"] as? [[String: Any]] else {
                print("Failed to load deck")
                completion([])
                return
            }

            let flashcards = cardDicts.compactMap { dict -> Flashcard? in
                guard let id = dict["id"] as? String,
                      let word = dict["word"] as? String,
                      let translation = dict["translation"] as? String else {
                    return nil
                }
                return Flashcard(id: id, word: word, translation: translation)
            }

            self.loadUserProgress(for: language, baseDeck: flashcards, completion: completion)
        }
    }

    private func loadUserProgress(for language: String, baseDeck: [Flashcard], completion: @escaping ([Flashcard]) -> Void) {
        guard let uid = auth.currentUser?.uid else {
            completion(baseDeck)
            return
        }

        let progressRef = db.collection("users").document(uid).collection("progress").document(language)

        progressRef.getDocument { snapshot, error in
            guard let data = snapshot?.data(),
                  let learnedMap = data["learnedMap"] as? [String: Bool] else {
                completion(baseDeck)
                return
            }

            let merged = baseDeck.map { card in
                var updated = card
                updated.isLearned = learnedMap[card.id] ?? false
                return updated
            }

            completion(merged)
        }
    }

    func markCardLearned(language: String, cardId: String, learned: Bool) {
        guard let uid = auth.currentUser?.uid else { return }

        let progressRef = db.collection("users")
            .document(uid)
            .collection("progress")
            .document(language)

        progressRef.setData([
            "learnedMap.\(cardId)": learned
        ], merge: true)
    }
}
