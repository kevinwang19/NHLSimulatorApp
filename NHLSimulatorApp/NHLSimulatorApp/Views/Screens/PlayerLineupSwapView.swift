//
//  PlayerLineupSwapView.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-08-08.
//

import SwiftUI

struct PlayerLineupSwapView: View {
    @EnvironmentObject var userInfo: UserInfo
    @EnvironmentObject var simulationState: SimulationState
    @ObservedObject var viewModel: PlayerLineupSwapViewModel = PlayerLineupSwapViewModel()
    @Binding var teamIndex: Int
    @Binding var playerID: Int
    @Binding var playerName: String
    @Binding var playerPosition: String
    @Binding var playerLineNumber: Int
    @Binding var lineupType: LineupType
    @State private var returnToEditLineupsView: Bool = false
    @State private var backButtonDisabled: Bool = false
    @State private var isPlayersLoaded: Bool = false
    @State private var swapPlayerID: Int = 0
    @State private var scrollOffset: CGFloat = 0
    @State private var isAtTop: Bool = true
    @State private var isAtBottom: Bool = false
    private let maxPlayersDisplayed: Int = 10
    private var blockWidth: CGFloat = 100
    private var blockHeight: CGFloat = 40
    
    init(teamIndex: Binding<Int>, playerID: Binding<Int>, playerName: Binding<String>, playerPosition: Binding<String>, playerLineNumber: Binding<Int>, lineupType: Binding<LineupType>) {
        self._teamIndex = teamIndex
        self._playerID = playerID
        self._playerName = playerName
        self._playerPosition = playerPosition
        self._playerLineNumber = playerLineNumber
        self._lineupType = lineupType
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                // Title and back button
                ScreenHeaderView(returnToPreviousView: $returnToEditLineupsView, backButtonDisabled: $backButtonDisabled)
                
                if isPlayersLoaded {
                    VStack {
                        // Instruction text
                        Text(LocalizedText.selectPlayerSwap.localizedString)
                            .appTextStyle()
                            .font(.footnote)
                            .frame(height: blockHeight, alignment: .center)
                            .padding(.vertical, Spacing.spacingSmall)
                            
                        HStack {
                            VStack {
                                // Lineup type of the selected player
                                let lineHeader = lineupType == .evenStrength ? playerPosition + "\(playerLineNumber)" : lineupType.rawValue + "\(playerLineNumber)"
                                
                                Text(lineHeader)
                                    .appTextStyle()
                                    .font(.callout)
                                    .frame(width: blockWidth, alignment: .center)
                                    .padding(.horizontal, Spacing.spacingSmall)
                                    
                                // Name of the selected player
                                Text(playerName.uppercased())
                                    .appTextStyle()
                                    .font(.footnote)
                                    .frame(width: blockWidth, height: blockHeight, alignment: .center)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.6)
                                    .padding(.horizontal, Spacing.spacingSmall)
                                    .appButtonStyle()
                            }
                                
                            VStack {
                                Text(" ")
                                    
                                Image(systemName: Symbols.leftRightArrow.rawValue)
                                    .appTextStyle()
                                    .font(.title3)
                            }
                                
                            VStack {
                                Text(" ")
                                    
                                // Grid view of players for swapping
                                playersGridView()
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                    
                // Swap button to perform the swap and return to previous view
                Button {
                    // Swap the two player lineups
                    viewModel.swapLineup(lineupType: lineupType, playerID: playerID, swapPlayerID: swapPlayerID) { lineupSwapped in
                        returnToEditLineupsView = lineupSwapped
                    }
                } label: {
                    Text(LocalizedText.swap.localizedString)
                        .appTextStyle()
                        .font(.headline)
                        .frame(maxWidth: 200, maxHeight: 75)
                        .appButtonStyle()
                }
                .padding(.bottom, Spacing.spacingLarge)
            }
            .padding(.horizontal, Spacing.spacingExtraSmall)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .appBackgroundStyle()
            .onAppear {
                // Fetch the teams
                viewModel.fetchTeams() { teamsFetched in
                    if teamsFetched, viewModel.teams.indices.contains(teamIndex) {
                        // Fetch the team lineup
                        viewModel.fetchTeamPositionPlayers(teamID: viewModel.teams[teamIndex].teamID, positionType: playerPosition) { lineupFetched in
                            isPlayersLoaded = lineupFetched
                        }
                    }
                }
            }
            .navigationDestination(isPresented: $returnToEditLineupsView, destination: {
                // Navigate to Main Sim page when back button is clicked
                EditLineupsView(teamIndex: $teamIndex)
                    .environmentObject(userInfo)
                    .environmentObject(simulationState)
                    .navigationBarHidden(true)
            })
        }
    }
    
    // View of the roster list
    @ViewBuilder
    private func playersGridView() -> some View {
        VStack {
            ZStack {
                let numSwappablePlayers = viewModel.lineupPlayers.count - 1
                let scrollViewHeight: CGFloat = numSwappablePlayers > maxPlayersDisplayed ? (blockHeight * CGFloat(maxPlayersDisplayed)) : (blockHeight * CGFloat(numSwappablePlayers))
                
                ScrollView(.vertical) {
                    LazyVStack(spacing: 0) {
                        // Rows of players
                        ForEach(viewModel.lineupPlayers, id: \.self) { player in
                            let name = viewModel.playerName(playerID: Int(player.playerID))
                            
                            if playerName != name {
                                Button {
                                    swapPlayerID = Int(player.playerID)
                                } label: {
                                    Text(name)
                                        .foregroundColor(player.playerID == Int64(swapPlayerID) ? Color.black : Color.white)
                                        .appTextStyle()
                                        .font(.footnote)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.6)
                                        .padding(.all, Spacing.spacingExtraSmall)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .frame(height: blockHeight)
                                .background(player.playerID == Int64(swapPlayerID) ? Color.white.cornerRadius(10) : Color.black.cornerRadius(10))
                            }
                        }
                    }
                    .background(GeometryReader { geometry in
                        Color.clear
                            .preference(key: ScrollOffsetPreferenceKey.self, value: geometry.frame(in: .named(ElementLabel.scroll.rawValue)).minY)
                    })
                    .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                        // Detect position of the scrolling for displaying the gradients
                        scrollOffset = value
                        isAtTop = (scrollOffset >= 0)
                        isAtBottom = (scrollOffset <= ((CGFloat(numSwappablePlayers - maxPlayersDisplayed) * blockHeight) * -1))
                    }
                }
                .coordinateSpace(name: ElementLabel.scroll.rawValue)
                .scrollDisabled(numSwappablePlayers <= maxPlayersDisplayed)
                .frame(height: scrollViewHeight)
                .appButtonStyle()
                
                // Gradient for more scrollable players
                if numSwappablePlayers > maxPlayersDisplayed {
                    VStack {
                        if !isAtTop {
                            LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.7), Color.clear]), startPoint: .top, endPoint: .bottom)
                                .frame(height: blockHeight)
                                .cornerRadius(10)
                        }
                        Spacer()
                        if !isAtBottom {
                            LinearGradient(gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.7)]), startPoint: .top, endPoint: .bottom)
                                .frame(height: blockHeight)
                                .cornerRadius(10)
                        }
                    }
                }
            }
            .frame(maxHeight: blockHeight * CGFloat(maxPlayersDisplayed))
        }
    }
}
