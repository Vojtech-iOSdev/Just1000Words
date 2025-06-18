//
//  Models.swift
//  Just1000Words
//
//  Created by Vojtěch Kalivoda on 6/18/25.
//



import Foundation

struct Flashcard: Identifiable, Codable, Equatable {
    let id: UUID
    let word: String
    let translation: String
}

enum Language: String, CaseIterable, Identifiable, Codable {
    case spanish = "Spanish"
    case russian = "Russian"
//    case french = "French"

    var id: String { rawValue }
}

struct LanguageDeck: Codable {
    let language: Language
    let flashcards: [Flashcard]
}


// Auth
struct UserProfile: Codable {
    var name: String
    var languages: [String]
}

struct UserFlashcard: Codable, Identifiable {
    var id = UUID()
    var word: String
    var translation: String
    var isLearned: Bool
}
