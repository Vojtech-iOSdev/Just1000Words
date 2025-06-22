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
    @Published var answers: [Flashcard] = []
    @Published var selectedAnswer: Flashcard?
    @Published var availableLanguages: [Language] = Language.allCases
    @Published var buttonsDisabled: Bool = false
    @Published var showingLanguageSheet: Bool = false
    @Published var practiceModeON: Bool = false
    
    @Published var correctCount = 0
    @Published var incorrectCount = 0
    @Published var totalCardCount: Int = 0
    @Published var learnedCardCount: Int = 0
    
    @Published var currentUser: User?
    @Published var selectedLanguages: [Language] = []
    @Published var selectedLanguage: Language = .spanish
    @Published var errorMessage: String?
    @Published var lastResetDate: Date?
    @Published var learnedToday: [Language: Int] = [:]
    @Published var learnedTodayCount: Int = 0
    @Published var dailyGoal: Int = 50
        
    private let authService = FirebaseAuthService.shared
    private let flashcardRepository = FirebaseFlashcardRepository()
    
    // Fetch the current user's document from Firestore
    func getCurrentUser() {
        guard let uid = authService.currentUserId() else {
            self.currentUser = nil
            return
        }
        
        flashcardRepository.db.collection("users").document(uid).getDocument { document, error in
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
                
                if let resetTimestamp = data["lastReset"] as? Timestamp {
                    self.lastResetDate = resetTimestamp.dateValue()
                }
                
                if let dailyData = data["dailyProgress"] as? [String: Int] {
                    self.learnedToday = dailyData.compactMapKeys { Language(rawValue: $0) }
                    self.learnedTodayCount = dailyData.values.reduce(0, +)
                }
                
                // Reset if needed or when its daily reset time(1am)
                if let lastReset = self.lastResetDate, Calendar.current.isDateInToday(lastReset) == false {
                    self.resetDailyProgress()
                }
            }
        }
    }
    
    func resetDailyProgress() {
        learnedToday = [:]
        learnedTodayCount = 0
        lastResetDate = Date()
        guard let uid = authService.currentUserId() else { return }
        let userRef = flashcardRepository.db.collection("users").document(uid)
        userRef.updateData([
            "dailyProgress": [:],
            "totalLearnedToday": 0,
            "lastReset": Timestamp(date: lastResetDate!)
        ])
    }
    
    func practiceLearnedCards() {
        practiceModeON = true
        loadDeck(for: selectedLanguage.rawValue)
    }

    func loadDeck(for language: String?, dailyLimit: Int = 50) {
        guard  let language = language else { return }
//        guard let languageEnumed = Language(rawValue: language) else { return }
//        selectedLanguage = languageEnumed
        flashcardRepository.fetchDeck(for: language) { [weak self] cards in
            DispatchQueue.main.async {
                self?.flashcards = cards.filter { self?.practiceModeON == true ? $0.isLearned : !$0.isLearned }
                self?.totalCardCount = cards.count
                self?.learnedCardCount = cards.filter { $0.isLearned }.count
                if self?.practiceModeON == true {
                    self?.showNextCardForPractice()
                } else {
                    self?.showNextCard()
                }
                print("debug \(String(describing: self?.flashcards))")
            }
        }
    }
        
    func addLanguageToUser(_ language: String) {
        guard let uid = authService.currentUserId() else { return }
        guard let languageEnumed = Language(rawValue: language) else { return }
        
        let userRef = flashcardRepository.db.collection("users").document(uid)
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
            learnedCardCount += 1
            learnedToday[selectedLanguage, default: 0] += 1
            learnedTodayCount += 1

            if let uid = currentUser?.id {
                let userRef = flashcardRepository.db.collection("users").document(uid)
                let key = selectedLanguage.rawValue
                userRef.updateData([
                    "dailyProgress.\(key)": learnedToday[selectedLanguage] ?? 0,
                    "totalLearnedToday": learnedTodayCount
                ])
            }
            flashcardRepository.markCardLearned(language: language, cardId: correctCard.id, learned: true)
        } else {
            incorrectCount += 1
        }
        
        buttonsDisabled = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if selectedAnswer == correctCard {
                self.flashcards.removeAll { $0.id == correctCard.id }
            }
            self.answers = []
            self.selectedAnswer = nil
            self.showNextCard()
            self.buttonsDisabled = false
        }
    }
    
    func showNextCardForPractice() {
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
    
    func checkAnswerForPractice(_ selectedAnswer: Flashcard) {
        guard let correctCard = currentCard else { return }
        self.selectedAnswer = selectedAnswer

        if selectedAnswer == correctCard {
            correctCount += 1
        } else {
            incorrectCount += 1
        }
        
        buttonsDisabled = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if selectedAnswer == correctCard {
                self.flashcards.removeAll { $0.id == correctCard.id }
            }
            self.answers = []
            self.selectedAnswer = nil
            self.showNextCardForPractice()
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
