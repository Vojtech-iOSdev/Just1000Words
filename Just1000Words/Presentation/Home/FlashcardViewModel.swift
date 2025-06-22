//
//  FlashcardViewModel.swift
//  Just1000Words
//
//  Created by Vojtěch Kalivoda on 6/18/25.
//


import Foundation
import SwiftUI
import FirebaseFirestore

// VERSION 3
class FlashcardViewModel: ObservableObject {
    @Published var flashcards: [Flashcard] = []
    @Published var currentCard: Flashcard?
    @Published var correctCount = 0
    @Published var incorrectCount = 0
    @Published var answers: [Flashcard] = []
    @Published var selectedAnswer: Flashcard?
    @Published var buttonsDisabled: Bool = false
    
    @Published var currentUser: User?
    @Published var selectedLanguages: [Language] = []
    @Published var selectedLanguage: Language = .spanish
    @Published var errorMessage: String?
        
    private let db = Firestore.firestore()
    private let authService = FirebaseAuthService.shared
    private let flashcardRepository = FirebaseFlashcardRepository()
    
    // Fetch the current user's document from Firestore
    func getCurrentUser() {
        guard let uid = authService.currentUserId() else {
            self.currentUser = nil
            return
        }
        
        db.collection("users").document(uid).getDocument { document, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                self.currentUser = nil
                self.selectedLanguages = []
                return
            }
            
            guard let document = document, document.exists,
                  let data = document.data(),
                  let user = User(id: document.documentID, data: data) else {
                self.currentUser = nil
                self.selectedLanguages = []
                return
            }
            
            DispatchQueue.main.async {
                self.currentUser = user
                self.selectedLanguages = user.languages
                if !user.languages.contains(self.selectedLanguage) {
                    self.selectedLanguage = user.languages.first ?? .spanish
                }
            }
        }
    }

    func loadDeck(for language: String) {
        guard let languageEnumed = Language(rawValue: language) else { return }
        selectedLanguage = languageEnumed
        flashcardRepository.fetchDeck(for: language) { [weak self] cards in
            DispatchQueue.main.async {
                self?.flashcards = cards.filter { !$0.isLearned }
                self?.showNextCard()
            }
        }
    }
    
//    func loadUserLanguages() {
//        guard let uid = authService.currentUserId() else { return }
//
//        db.collection("users").document(uid).getDocument { snapshot, error in
//            guard let data = snapshot?.data(),
//                  let langs = data["languages"] as? [String] else { return }
//
//            DispatchQueue.main.async {
//                self.availableUserLanguages = langs
//                if self.selectedLanguage.isEmpty, let first = langs.first {
//                    self.selectedLanguage = first
//                }
//            }
//        }
//    }
    
    func addLanguageToUser(_ language: String) {
        guard let uid = authService.currentUserId() else { return }
        guard let languageEnumed = Language(rawValue: language) else { return }
        
        let userRef = db.collection("users").document(uid)
        userRef.updateData([
            "languages": FieldValue.arrayUnion([language])
        ]) { error in
            guard error == nil else {
                if let error = error {
                    print("Failed to add language: \(error.localizedDescription)")
                }
                return
            }
            DispatchQueue.main.async {
                if !self.selectedLanguages.contains(languageEnumed) {
                    self.selectedLanguages.append(languageEnumed)
                }
                if !self.selectedLanguages.contains(self.selectedLanguage) {
                    self.selectedLanguage = languageEnumed
                }
            }
        }
        
        getCurrentUser()
        loadDeck(for: language)
    }

    func showNextCard() {
        guard !flashcards.isEmpty else {
            currentCard = nil
            return
        }
        currentCard = flashcards.randomElement()
        
        if let correctCard = currentCard {
            let incorrectCards = flashcards.filter { $0 != correctCard }.shuffled().prefix(3)
            answers = Array(incorrectCards) + [correctCard]
            answers.shuffle()
        }
    }

    func checkAnswer(_ selectedAnswer: Flashcard) {
        guard let correctCard = currentCard else { return }
        let language = selectedLanguage.rawValue
        self.selectedAnswer = selectedAnswer

        if selectedAnswer == correctCard {
            correctCount += 1
            flashcardRepository.markCardLearned(language: language, cardId: correctCard.id, learned: true)
        } else {
            incorrectCount += 1
        }
        
        buttonsDisabled = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if selectedAnswer == correctCard {
                self.flashcards.removeAll { $0.id == correctCard.id }
            }
            self.answers = []
            self.selectedAnswer = nil
            self.showNextCard()
            self.buttonsDisabled = false
        }
    }
    
//    func loadNewWord() {
    //        guard let deck = allDecks[selectedLanguage], !deck.isEmpty else { return }
    //        currentWord = deck.randomElement()
    //        if let correct = currentWord {
    //            var incorrectOptions = deck.filter { $0 != correct }.shuffled().prefix(3)
    //            options = Array(incorrectOptions) + [correct]
    //            options.shuffle()
    //            selectedOption = nil
    //        }
    //    }
    
//        func select(selectedAnswer: Flashcard) {
//            guard let currentCard = currentCard else { return }
//            self.selectedAnswer = selectedAnswer
//            if selectedAnswer == currentCard {
//                correctCount += 1
//            } else {
//                incorrectCount += 1
//            }
//    
//            buttonsDisabled = true
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                self.loadNewWord()
//                self.buttonsDisabled = false
//    
//            }
//        }
}


// VERSION 2
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
////    @Published var availableUserLanguages: [String] = []
////    @Published var selectedLanguage: String = ""
//
////    private let db = Firestore.firestore()
////    private let authService = FirebaseAuthService.shared
//
//    private var allDecks: [Language: [Flashcard]] = [:]
//    private let flashcardRepository: FlashcardRepositoryProtocol
//
//    init(flashcardRepository: FlashcardRepositoryProtocol = FirebaseFlashcardRepository()) {
//        self.flashcardRepository = flashcardRepository
//        loadDecks()
////        loadUserLanguages()
//    }
//
//
////        func loadUserLanguages() {
////            guard let uid = authService.currentUserId() else { return }
////
////            db.collection("users").document(uid).getDocument { snapshot, error in
////                guard let data = snapshot?.data(),
////                      let langs = data["languages"] as? [String] else { return }
////
////                DispatchQueue.main.async {
////                    self.availableUserLanguages = langs
////                    if self.selectedLanguage.isEmpty, let first = langs.first {
////                        self.selectedLanguage = first
////                    }
////                }
////            }
////        }
////
////        func addLanguageToUser(_ language: String) {
////            guard let uid = authService.currentUserId() else { return }
////
////            let userRef = db.collection("users").document(uid)
////            userRef.updateData([
////                "languages": FieldValue.arrayUnion([language])
////            ]) { error in
////                if let error = error {
////                    print("Failed to add language: \(error)")
////                } else {
////                    DispatchQueue.main.async {
////                        if !self.availableUserLanguages.contains(language) {
////                            self.availableUserLanguages.append(language)
////                        }
////                        if self.selectedLanguage.isEmpty {
////                            self.selectedLanguage = language
////                        }
////                    }
////                }
////            }
////        }
//
//
//    private func loadDecks() {
//        for language in Language.allCases {
//            flashcardRepository.loadDeck(for: language) { [weak self] result in
//                DispatchQueue.main.async {
//                    switch result {
//                    case .success(let flashcards):
//                        self?.allDecks[language] = flashcards
//                        if language == self?.selectedLanguage {
//                            self?.loadNewWord()
//                        }
//                    case .failure(let error):
//                        print("Error loading deck for \(language): \(error)")
//                    }
//                }
//            }
//        }
//    }
//
//    func loadNewWord() {
//        guard let deck = allDecks[selectedLanguage], !deck.isEmpty else { return }
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
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//            self.loadNewWord()
//            self.buttonsDisabled = false
//
//        }
//    }
//}



// VERSION 1
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
