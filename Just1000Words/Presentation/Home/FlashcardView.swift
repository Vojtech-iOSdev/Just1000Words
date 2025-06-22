//
//  FlashcardView.swift
//  Just1000Words
//
//  Created by Vojtěch Kalivoda on 6/18/25.
//

import SwiftUI

struct FlashcardView: View {
    @ObservedObject var authVM: AuthViewModel
    @StateObject private var viewModel = FlashcardViewModel()
    
    var body: some View {
        VStack(spacing: 16) {
            CustomButton1(title: "Add Language", action: {
                viewModel.showingLanguageSheet = true
            })
            
            if !viewModel.selectedLanguages.isEmpty {
                Picker("Language", selection: $viewModel.selectedLanguage) {
                    ForEach(viewModel.selectedLanguages, id: \.self) { language in
                        Text(language.rawValue.capitalized).tag(language)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                if !viewModel.totalCardCount.words.isEmpty {
                    Text("✅ Learned: \(viewModel.learnedCardCount) / \(viewModel.totalCardCount)")
                        .font(.headline)
                        .padding(.bottom, 10)
                }
                
                if let currentCard = viewModel.currentCard {
                    Text(currentCard.word)
                        .font(.largeTitle)
                        .padding()
                }
                
                if viewModel.flashcards.isEmpty {
                    Text("DECK COMPLETED")
                        .font(.largeTitle)
                        .padding()
                } else {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                        ForEach(viewModel.answers) { answeredCard in
                            Button(action: {
                                viewModel.checkAnswer(answeredCard)
                            }) {
                                Text(answeredCard.translation)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        viewModel.selectedAnswer == answeredCard
                                        ? (answeredCard.translation == viewModel.currentCard?.translation ? Color.green : Color.red)
                                        : Color.blue
                                    )
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            .disabled(viewModel.buttonsDisabled)
                        }
                    }
                    .padding()
                }
                
                HStack(spacing: 20) {
                    Text("✅ Correct: \(viewModel.correctCount)")
                    Text("❌ Incorrect: \(viewModel.incorrectCount)")
                }
                .font(.headline)
                .padding()
            }
            
            CustomButton1(title: "Logout", action: authVM.logout)
            
            Spacer()
        }
        .onAppear {
            viewModel.getCurrentUser()
            viewModel.loadDeck(for: viewModel.selectedLanguage.rawValue)
        }
        .onChange(of: viewModel.selectedLanguage) { language in
            viewModel.loadDeck(for: language.rawValue)
            viewModel.correctCount = 0
            viewModel.incorrectCount = 0
        }
        .sheet(isPresented: $viewModel.showingLanguageSheet) {
            VStack {
                Text("Choose a Language").font(.headline)
                ForEach(viewModel.availableLanguages, id: \.self) { language in
                    Button(language.rawValue.capitalized) {
                        viewModel.addLanguageToUser(language.rawValue)
                        viewModel.showingLanguageSheet = false
                    }
                    .padding()
                    .disabled(viewModel.selectedLanguages.contains(language))
                    .foregroundColor(viewModel.selectedLanguages.contains(language) ? Color(UIColor.systemGray2) : .primary)
                }
            }
            .padding()
        }
    }
}


//#Preview {
//    FlashcardView(authVM: <#T##AuthViewModel#>, viewModel: <#T##arg#>, showingLanguageSheet: <#T##arg#>, availableLanguages: <#T##arg#>)
//}
