//
//  TeamDropDownMenuView.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-07-16.
//

import SwiftUI

struct TeamDropDownMenuView: View {
    @Binding var selectedTeamIndex: Int
    @Binding var showDropdown: Bool
    @State private var scrollOffset: CGFloat = 0
    @State private var isAtTop: Bool = true
    @State private var isAtBottom: Bool = false
    var teams: [Team]
    var maxTeamsDisplayed: Int
    @Binding var isDisabled: Bool
    private let menuWidth: CGFloat = 250
    private let buttonHeight: CGFloat = 50

    var body: some View {
        VStack {
            VStack(spacing: 0) {
                // Selected team
                Button(action: {
                        showDropdown.toggle()
                }, label: {
                    if teams.indices.contains(selectedTeamIndex) {
                        HStack(spacing: 0) {
                            Text(teams[selectedTeamIndex].fullName.uppercased())
                                .font(.footnote)
                            
                            Spacer()
                            
                            Image(systemName: Icon.chevronDown)
                                .rotationEffect(.degrees((showDropdown ?  -180 : 0)))
                        }
                        .appTextStyle()
                    }
                })
                .padding(.horizontal, Spacing.spacingSmall)
                .frame(width: menuWidth, height: buttonHeight, alignment: .leading)

                // Selection menu
                if showDropdown {
                    let scrollViewHeight: CGFloat = teams.count > maxTeamsDisplayed ? (buttonHeight * CGFloat(maxTeamsDisplayed)) : (buttonHeight * CGFloat(teams.count))
                    
                    ZStack {
                        // Scrollable list of teams
                        ScrollView {
                            LazyVStack(spacing: 0) {
                                ForEach(0..<teams.count, id: \.self) { index in
                                    Button(action: {
                                        selectedTeamIndex = index
                                        showDropdown.toggle()
                                    }, label: {
                                        HStack {
                                            Text(teams[index].fullName.uppercased())
                                                .font(.footnote)
                                            
                                            Spacer()
                                            
                                            if (index == selectedTeamIndex) {
                                                Image(systemName: Icon.checkmarkCircleFill)
                                                
                                            }
                                        }
                                        .appTextStyle()
                                    })
                                    .padding(.horizontal, Spacing.spacingSmall)
                                    .frame(width: menuWidth, height: buttonHeight, alignment: .leading)
                                }
                            }
                            .background(GeometryReader { geometry in
                                Color.clear
                                .preference(key: ScrollOffsetPreferenceKey.self, value: geometry.frame(in: .named(ElementLabel.scroll.rawValue)).minY)
                            })
                            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                                // Detect position of the drop down scrolling for displaying the gradients
                                scrollOffset = value
                                isAtTop = (scrollOffset >= 0)
                                isAtBottom = (scrollOffset <= ((CGFloat(teams.count - maxTeamsDisplayed) * buttonHeight) * -1))
                            }
                        }
                        .coordinateSpace(name: ElementLabel.scroll.rawValue)
                        .scrollDisabled(teams.count <= maxTeamsDisplayed)
                        .frame(height: scrollViewHeight)
                        
                        // Gradient for more scrollable teams
                        if teams.count > maxTeamsDisplayed {
                            VStack {
                                if !isAtTop {
                                    LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.7), Color.clear]), startPoint: .top, endPoint: .bottom)
                                        .frame(height: buttonHeight)
                                        .cornerRadius(10)
                                }
                                Spacer()
                                if !isAtBottom {
                                    LinearGradient(gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.7)]), startPoint: .top, endPoint: .bottom)
                                        .frame(height: buttonHeight)
                                        .cornerRadius(10)
                                }
                            }
                        }
                    }
                }
            }
            .appButtonStyle()
        }
        .frame(width: menuWidth, height: buttonHeight, alignment: .top)
        .zIndex(100)
        .disabled(isDisabled)
    }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {}
}
