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
    @State private var isPlayersLoaded: Bool = false
    @State private var swapPlayerID: Int = 0
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
                if isPlayersLoaded {
                    // Title and back button
                    ScreenHeaderView(returnToPreviousView: $returnToEditLineupsView)
                    
                    Text(LocalizedText.selectPlayerSwap.localizedString)
                        .appTextStyle()
                        .font(.callout)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, Spacing.spacingSmall)
                    
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
                        
                        // Grid view of players for swapping
                        playersGridView()

                    }
                    .padding(.top, Spacing.spacingMedium)
                    
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
                    .padding(.vertical, Spacing.spacingMedium)
                    
                    Spacer()
                } else {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                }
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
    
    @ViewBuilder
    private func playersGridView() -> some View {
        VStack {
            ScrollView(.vertical) {
                LazyVStack {
                    // Rows of players
                    ForEach(viewModel.lineupPlayers, id: \.self) { player in
                        let name = viewModel.playerName(playerID: Int(player.playerID))
                        
                        if playerName != name {
                            Button {
                                swapPlayerID = Int(player.playerID)
                            } label: {
                                Text(name)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .foregroundColor(player.playerID == Int64(swapPlayerID) ? Color.black : Color.white)
                            .appTextStyle()
                            .font(.footnote)
                            .padding(.all, Spacing.spacingExtraSmall)
                            .background(player.playerID == Int64(swapPlayerID) ? Color.white.cornerRadius(10) : Color.black.cornerRadius(10))
                        }
                    }
                }
                .padding(Spacing.spacingExtraSmall)
            }
            .appButtonStyle()
        }
    }
}
