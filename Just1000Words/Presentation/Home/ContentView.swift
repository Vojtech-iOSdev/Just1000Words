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
    @State private var availableLanguages = ["Spanish", "Russian"]

    var body: some View {
        VStack(spacing: 16) {
            Button("Add Language") {
                showingLanguageSheet = true
            }

//            Picker("Language", selection: $viewModel.selectedLanguage) {
//                ForEach(viewModel.availableUserLanguages, id: \.self) { lang in
//                    Text(lang).tag(lang)
//                }
//            }
//            .pickerStyle(SegmentedPickerStyle())

            Picker("Language", selection: $viewModel.selectedLanguage) {
                ForEach(Language.allCases) { language in
                    Text(language.rawValue).tag(language)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            if let word = viewModel.currentWord {
                Text(word.word)
                    .font(.largeTitle)
                    .padding()
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                ForEach(viewModel.options) { option in
                    Button(action: {
                        viewModel.select(option: option)
                    }) {
                        Text(option.translation)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                viewModel.selectedOption == option
                                    ? (option == viewModel.currentWord ? Color.green : Color.red)
                                    : Color.blue
                            )
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(viewModel.buttonsDisabled)
                }
            }
            .padding()

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
        .onChange(of: viewModel.selectedLanguage) {
            viewModel.correctCount = 0
            viewModel.incorrectCount = 0
        }
        .sheet(isPresented: $showingLanguageSheet) {
                VStack {
                    Text("Choose a Language").font(.headline)
                    ForEach(availableLanguages, id: \.self) { language in
                        Button(language) {
//                            viewModel.addLanguageToUser(language)
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
