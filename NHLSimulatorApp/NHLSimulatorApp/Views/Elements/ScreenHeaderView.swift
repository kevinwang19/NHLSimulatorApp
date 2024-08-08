//
//  ScreenHeaderView.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-08-07.
//

import SwiftUI

struct ScreenHeaderView: View {
    @Binding var returnToPreviousView: Bool
    
    var body: some View {
        ZStack {
            Button {
                returnToPreviousView = true
            } label: {
                HStack {
                    Image(systemName: Symbols.leftArrow.rawValue)
                        .labelStyle(IconOnlyLabelStyle())
                    
                    Text(LocalizedStringKey(LocalizedText.back.rawValue))
                }
                .appTextStyle()
                .font(.footnote)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(LocalizedStringKey(LocalizedText.nhlSimulator.rawValue))
                .appTextStyle()
                .font(.headline)
                .padding(.top, Spacing.spacingExtraSmall)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}
