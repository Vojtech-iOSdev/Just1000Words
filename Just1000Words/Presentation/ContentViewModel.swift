//
//  ContentViewModel.swift
//  Just1000Words
//
//  Created by Vojtěch Kalivoda on 6/18/25.
//


import Foundation
import SwiftUI
import FirebaseFirestore

class FlashcardViewModel: ObservableObject {
    @Published var selectedLanguage: Language = .spanish {
        didSet { loadNewWord() }
    }
    @Published var currentWord: Flashcard?
    @Published var options: [Flashcard] = []
    @Published var correctCount: Int = 0
    @Published var incorrectCount: Int = 0
    @Published var selectedOption: Flashcard?
    @Published var buttonsDisabled: Bool = false
//    @Published var availableUserLanguages: [String] = []
//    @Published var selectedLanguage: String = ""

//    private let db = Firestore.firestore()
//    private let authService = FirebaseAuthService.shared
    
    private var allDecks: [Language: [Flashcard]] = [:]
    private let repository: FlashcardRepositoryProtocol

    init(repository: FlashcardRepositoryProtocol = FirebaseFlashcardRepository()) {
        self.repository = repository
        loadDecks()
//        loadUserLanguages()
    }
    

//        func loadUserLanguages() {
//            guard let uid = authService.currentUserId() else { return }
//
//            db.collection("users").document(uid).getDocument { snapshot, error in
//                guard let data = snapshot?.data(),
//                      let langs = data["languages"] as? [String] else { return }
//
//                DispatchQueue.main.async {
//                    self.availableUserLanguages = langs
//                    if self.selectedLanguage.isEmpty, let first = langs.first {
//                        self.selectedLanguage = first
//                    }
//                }
//            }
//        }
//
//        func addLanguageToUser(_ language: String) {
//            guard let uid = authService.currentUserId() else { return }
//
//            let userRef = db.collection("users").document(uid)
//            userRef.updateData([
//                "languages": FieldValue.arrayUnion([language])
//            ]) { error in
//                if let error = error {
//                    print("Failed to add language: \(error)")
//                } else {
//                    DispatchQueue.main.async {
//                        if !self.availableUserLanguages.contains(language) {
//                            self.availableUserLanguages.append(language)
//                        }
//                        if self.selectedLanguage.isEmpty {
//                            self.selectedLanguage = language
//                        }
//                    }
//                }
//            }
//        }
    

    private func loadDecks() {
        for language in Language.allCases {
            repository.loadDeck(for: language) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let flashcards):
                        self?.allDecks[language] = flashcards
                        if language == self?.selectedLanguage {
                            self?.loadNewWord()
                        }
                    case .failure(let error):
                        print("Error loading deck for \(language): \(error)")
                    }
                }
            }
        }
    }

    func loadNewWord() {
        guard let deck = allDecks[selectedLanguage], !deck.isEmpty else { return }
        currentWord = deck.randomElement()
        if let correct = currentWord {
            var incorrectOptions = deck.filter { $0 != correct }.shuffled().prefix(3)
            options = Array(incorrectOptions) + [correct]
            options.shuffle()
            selectedOption = nil
        }
    }

    func select(option: Flashcard) {
        selectedOption = option
        if option == currentWord {
            correctCount += 1
        } else {
            incorrectCount += 1
        }

        buttonsDisabled = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.loadNewWord()
            self.buttonsDisabled = false

        }
    }
}

//class FlashcardViewModel: ObservableObject {
//    @Published var selectedLanguage: Language = .spanish {
//        didSet { loadNewWord() }
//    }
//    @Published var currentWord: Flashcard?
//    @Published var options: [Flashcard] = []
//    @Published var correctCount: Int = 0
//    @Published var incorrectCount: Int = 0
//    @Published var selectedOption: Flashcard?
//    @Published var buttonsDisabled: Bool = false
//    
//    private var decks: [Language: [Flashcard]] = [:]
//
//    init() {
//        setupDecks()
//        loadNewWord()
//    }
//
//    private func setupDecks() {
//        decks[.spanish] = [
//            Flashcard(word: "hola", translation: "hello"),
//            Flashcard(word: "adios", translation: "goodbye"),
//            Flashcard(word: "gracias", translation: "thank you"),
//            Flashcard(word: "por favor", translation: "please"),
//            Flashcard(word: "lo siento", translation: "sorry"),
//            Flashcard(word: "salud", translation: "bless you"),
//            Flashcard(word: "bien", translation: "well"),
//            Flashcard(word: "mal", translation: "bad"),
//            Flashcard(word: "amigo", translation: "friend"),
//            Flashcard(word: "familia", translation: "family")
//        ]
//
//        decks[.russian] = [
//            Flashcard(word: "привет", translation: "hello"),
//            Flashcard(word: "пока", translation: "goodbye"),
//            Flashcard(word: "спасибо", translation: "thank you"),
//            Flashcard(word: "пожалуйста", translation: "please"),
//            Flashcard(word: "извини", translation: "sorry"),
//            Flashcard(word: "будь здоров", translation: "bless you"),
//            Flashcard(word: "хорошо", translation: "well"),
//            Flashcard(word: "плохо", translation: "bad"),
//            Flashcard(word: "друг", translation: "friend"),
//            Flashcard(word: "семья", translation: "family")
//        ]
//        
//        decks[.french] = [
//            Flashcard(word: "bonjour", translation: "hello"),
//            Flashcard(word: "au revoir", translation: "goodbye"),
//            Flashcard(word: "merci", translation: "thank you"),
//            Flashcard(word: "sil te plais", translation: "please"),
//            Flashcard(word: "desole", translation: "sorry"),
//            Flashcard(word: "bien", translation: "well"),
//            Flashcard(word: "mal", translation: "bad"),
//            Flashcard(word: "amie", translation: "friend"),
//            Flashcard(word: "famillie", translation: "family")
//        ]
//
//    }
//
//    func loadNewWord() {
//        guard let deck = decks[selectedLanguage] else { return }
//        currentWord = deck.randomElement()
//        if let correct = currentWord {
//            var incorrectOptions = deck.filter { $0 != correct }.shuffled().prefix(3)
//            options = Array(incorrectOptions) + [correct]
//            options.shuffle()
//            selectedOption = nil
//        }
//    }
//
//    func select(option: Flashcard) {
//        selectedOption = option
//        if option == currentWord {
//            correctCount += 1
//        } else {
//            incorrectCount += 1
//        }
//
//        buttonsDisabled = true
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
//            self.loadNewWord()
//            self.buttonsDisabled = false
//        }
//    }
//}
