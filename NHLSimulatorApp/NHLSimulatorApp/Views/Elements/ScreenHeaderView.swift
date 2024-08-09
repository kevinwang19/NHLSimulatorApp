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
                    
                    Text(LocalizedText.back.localizedString)
                }
                .appTextStyle()
                .font(.footnote)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(LocalizedText.nhlSimulator.localizedString)
                .appTextStyle()
                .font(.headline)
                .padding(.top, Spacing.spacingExtraSmall)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}
