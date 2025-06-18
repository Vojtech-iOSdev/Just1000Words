//
//  MockFirebaseFlashcardRepository.swift
//  Just1000Words
//
//  Created by Vojtěch Kalivoda on 6/18/25.
//

import Foundation

protocol FlashcardRepositoryProtocol {
    func loadDeck(for language: Language, completion: @escaping (Result<[Flashcard], Error>) -> Void)
}

class MockFirebaseFlashcardRepository: FlashcardRepositoryProtocol {
    private let mockData: [Language: [Flashcard]] = [
        .spanish: [
            Flashcard(id: UUID(), word: "hola", translation: "hello"),
            Flashcard(id: UUID(), word: "adios", translation: "goodbye"),
            Flashcard(id: UUID(), word: "gracias", translation: "thank you"),
            Flashcard(id: UUID(), word: "por favor", translation: "please"),
            Flashcard(id: UUID(), word: "lo siento", translation: "sorry"),
            Flashcard(id: UUID(), word: "salud", translation: "bless you"),
            Flashcard(id: UUID(), word: "bien", translation: "well"),
            Flashcard(id: UUID(), word: "mal", translation: "bad"),
            Flashcard(id: UUID(), word: "amigo", translation: "friend"),
            Flashcard(id: UUID(), word: "familia", translation: "family")
        ],
        .russian: [
            Flashcard(id: UUID(), word: "привет", translation: "hello"),
            Flashcard(id: UUID(), word: "пока", translation: "goodbye"),
            Flashcard(id: UUID(), word: "спасибо", translation: "thank you"),
            Flashcard(id: UUID(), word: "пожалуйста", translation: "please"),
            Flashcard(id: UUID(), word: "извини", translation: "sorry"),
            Flashcard(id: UUID(), word: "будь здоров", translation: "bless you"),
            Flashcard(id: UUID(), word: "хорошо", translation: "well"),
            Flashcard(id: UUID(), word: "плохо", translation: "bad"),
            Flashcard(id: UUID(), word: "друг", translation: "friend"),
            Flashcard(id: UUID(), word: "семья", translation: "family")
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
