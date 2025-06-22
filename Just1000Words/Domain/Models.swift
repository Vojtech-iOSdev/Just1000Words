//
//  Models.swift
//  Just1000Words
//
//  Created by Vojtěch Kalivoda on 6/18/25.
//



import Foundation

//struct Flashcard: Identifiable, Codable, Equatable {
//    let id: UUID
//    let word: String
//    let translation: String
//}

struct Flashcard: Identifiable, Codable, Equatable {
    let id: String
    let word: String
    let translation: String
    var isLearned: Bool = false
}

enum Language: String, CaseIterable, Identifiable, Codable {
    case spanish = "spanish"
    case russian = "russian"
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

struct User {
    let id: String
    let name: String
    let languages: [Language]

    init?(id: String, data: [String: Any]) {
        guard let name = data["name"] as? String,
              let languageStrings = data["languages"] as? [String] else {
            return nil
        }
        self.id = id
        self.name = name
        self.languages = languageStrings.compactMap { Language(rawValue: $0) }
    }
}
