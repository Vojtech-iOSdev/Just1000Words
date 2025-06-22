//
//  ContentView.swift
//  Just1000Words
//
//  Created by Vojtěch Kalivoda on 6/18/25.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var authVM: AuthViewModel
    @StateObject private var viewModel = FlashcardViewModel()
    @State private var showingLanguageSheet = false
    @State private var availableLanguages: [Language] = Language.allCases
    
    var body: some View {
        VStack(spacing: 16) {
            if viewModel.selectedLanguages.isEmpty {
                Button("Add Language") {
                    showingLanguageSheet = true
                }
                
                Button("Logout") {
                    authVM.logout()
                }
            } else {
                Button("Add Language") {
                    showingLanguageSheet = true
                }
                
                Picker("Language", selection: $viewModel.selectedLanguage) {
                    ForEach(viewModel.selectedLanguages, id: \.self) { language in
                        Text(language.rawValue).tag(language)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                //            Picker("Language", selection: $viewModel.selectedLanguage) {
                //                ForEach(Language.allCases) { language in
                //                    Text(language.rawValue).tag(language)
                //                }
                //            }
                //            .pickerStyle(SegmentedPickerStyle())
                //            .padding()
                
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
                
                Button("Logout") {
                    authVM.logout()
                }
                
                Spacer()
            }
        }
        .onAppear {
            viewModel.getCurrentUser()
        }
        .onChange(of: viewModel.selectedLanguage) { language in
            viewModel.loadDeck(for: language.rawValue)
            viewModel.correctCount = 0
            viewModel.incorrectCount = 0
        }
        .sheet(isPresented: $showingLanguageSheet) {
            VStack {
                Text("Choose a Language").font(.headline)
                ForEach(availableLanguages, id: \.self) { language in
                    Button(language.rawValue) {
                        viewModel.addLanguageToUser(language.rawValue)
                        showingLanguageSheet = false
                    }
                    .padding()
                }
            }
            .padding()
        }
    }
}


//#Preview {
//    ContentView(authVM: <#T##AuthViewModel#>, viewModel: <#T##arg#>, showingLanguageSheet: <#T##arg#>, availableLanguages: <#T##arg#>)
//}
