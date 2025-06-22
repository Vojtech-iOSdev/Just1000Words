//
//  CustomButton1.swift
//  Just1000Words
//
//  Created by Vojtěch Kalivoda on 6/22/25.
//

import SwiftUI

struct CustomButton1: View {
    let title: String
    let action:  () -> Void
    
    var body: some View {
        Button(title, action: action)
            .buttonStyle(BorderedButtonStyle())
    }
}
