//
//  AppTextStyle.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-07-11.
//

import SwiftUI

extension View {
    func appTextStyle() -> some View {
        self.modifier(TextStyle())
    }
    
    func appBackgroundStyle() -> some View {
        self.modifier(BackgroundStyle())
    }
    
    func appButtonStyle() -> some View {
        self.modifier(ButtonStyle())
    }
}

struct TextStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .bold()
            .fontDesign(.rounded)
            .foregroundColor(.white)
    }
}

struct BackgroundStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                Color.black
                    .opacity(0.7)
                    .ignoresSafeArea()
            )
    }
}

struct ButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.black)
            .cornerRadius(10)
    }
}
