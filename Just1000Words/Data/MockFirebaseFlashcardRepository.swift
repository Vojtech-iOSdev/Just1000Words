//
//  MockFirebaseFlashcardRepository.swift
//  Just1000Words
//
//  Created by Vojtěch Kalivoda on 6/18/25.
//

import Foundation

//protocol FlashcardRepositoryProtocol {
//    func loadDeck(for language: Language, completion: @escaping (Result<[Flashcard], Error>) -> Void)
//}

// protocol not used now but should be, will refactor clean architecture later
//class MockFirebaseFlashcardRepository: FlashcardRepositoryProtocol {
class MockFirebaseFlashcardRepository {
    private let mockData: [Language: [Flashcard]] = [
        .spanish: [
            Flashcard(id: "spanish0", word: "hola", translation: "hello"),
            Flashcard(id: "spanish1", word: "adios", translation: "goodbye"),
            Flashcard(id: "spanish2", word: "gracias", translation: "thank you"),
            Flashcard(id: "spanish3", word: "por favor", translation: "please"),
            Flashcard(id: "spanish4", word: "lo siento", translation: "sorry"),
            Flashcard(id: "spanish5", word: "salud", translation: "bless you"),
            Flashcard(id: "spanish6", word: "bien", translation: "well"),
            Flashcard(id: "spanish7", word: "mal", translation: "bad"),
            Flashcard(id: "spanish8", word: "amigo", translation: "friend"),
            Flashcard(id: "spanish9", word: "familia", translation: "family")
        ],
        .russian: [
            Flashcard(id: "russian0", word: "привет", translation: "hello"),
            Flashcard(id: "russian1", word: "пока", translation: "goodbye"),
            Flashcard(id: "russian2", word: "спасибо", translation: "thank you"),
            Flashcard(id: "russian3", word: "пожалуйста", translation: "please"),
            Flashcard(id: "russian4", word: "извини", translation: "sorry"),
            Flashcard(id: "russian5", word: "будь здоров", translation: "bless you"),
            Flashcard(id: "russian6", word: "хорошо", translation: "well"),
            Flashcard(id: "russian7", word: "плохо", translation: "bad"),
            Flashcard(id: "russian8", word: "друг", translation: "friend"),
            Flashcard(id: "russian9", word: "семья", translation: "family")
        ],
//        .french: [
//            Flashcard(id: UUID(),word: "bonjour", translation: "hello"),
//            Flashcard(id: UUID(),word: "au revoir", translation: "goodbye"),
//            Flashcard(id: UUID(),word: "merci", translation: "thank you"),
//            Flashcard(id: UUID(),word: "sil te plais", translation: "please"),
//            Flashcard(id: UUID(),word: "desole", translation: "sorry"),
//            Flashcard(id: UUID(),word: "bien", translation: "well"),
//            Flashcard(id: UUID(),word: "mal", translation: "bad"),
//            Flashcard(id: UUID(),word: "amie", translation: "friend"),
//            Flashcard(id: UUID(),word: "famillie", translation: "family")
//        ]
    ]

    func loadDeck(for language: Language, completion: @escaping (Result<[Flashcard], Error>) -> Void) {
        if let deck = mockData[language] {
            completion(.success(deck))
        } else {
            completion(.failure(NSError(domain: "No deck found", code: 404, userInfo: nil)))
        }
    }
}
