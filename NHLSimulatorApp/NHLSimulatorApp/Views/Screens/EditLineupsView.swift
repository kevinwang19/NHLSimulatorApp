//
//  EditLineupsView.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-08-05.
//

import SDWebImageSwiftUI
import SwiftUI

struct EditLineupsView: View {
    @EnvironmentObject var userInfo: UserInfo
    @EnvironmentObject var simulationState: SimulationState
    @ObservedObject var viewModel: EditLineupsViewModel = EditLineupsViewModel()
    @Binding var teamIndex: Int
    @State private var selectedTeamIndex: Int = -1
    @State private var showDropdown: Bool = false
    @State private var isDisabled: Bool = false
    @State private var showPlayerLineupSwapView: Bool = false
    @State private var returnToMainSimView: Bool = false
    @State private var isLineupLoaded: Bool = false
    @State private var selectedLineupType: LineupType = .evenStrength
    @State private var forwardPositions: [String] = [PositionType.leftWingers.rawValue, PositionType.centers.rawValue, PositionType.rightWingers.rawValue]
    @State private var defensePositions: [String] = [PositionType.leftDefensemen.rawValue, PositionType.rightDefensemen.rawValue]
    @State private var goaliePositions: [String] = [PositionType.goalies.rawValue]
    @State private var playerID: Int = 0
    @State private var playerName: String = ""
    @State private var playerPosition: String = ""
    @State private var playerLineNumber: Int = 0
    private var numEvenStrengthLines: [Int] = [4, 3, 2]
    private var numSpecialTeamsLines: Int = 2
    private var blockWidth: CGFloat = 80
    private var blockHeight: CGFloat = 40
    
    init(teamIndex: Binding<Int>) {
        self._teamIndex = teamIndex
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                // Title and back button
                ScreenHeaderView(returnToPreviousView: $returnToMainSimView, backButtonDisabled: $isDisabled)
                    
                HStack {
                    // Drop down menu of all teams
                    TeamDropDownMenuView(selectedTeamIndex: $selectedTeamIndex, showDropdown: $showDropdown, teams: viewModel.teams, maxTeamsDisplayed: 6, isDisabled: $isDisabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                    // Selected team logo
                    if viewModel.teams.indices.contains(selectedTeamIndex) {
                        let url = URL(string: viewModel.teams[selectedTeamIndex].logo)
                        
                        WebImage(url: url)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 50)
                            .padding(.trailing, Spacing.spacingSmall)
                    } else {
                        Rectangle()
                            .fill(.clear)
                            .scaledToFit()
                            .frame(height: 50)
                            .padding(.trailing, Spacing.spacingSmall)
                    }
                }
                .zIndex(1)
                    
                // Picker between powerplay, penalty kill, or overtime lineup
                lineupTypePicker()
                    .padding(.top, Spacing.spacingExtraSmall)
                
                if isLineupLoaded {
                    if selectedLineupType == .evenStrength {
                        VStack {
                            // Forward lineups
                            evenStrengthLineups(numLines: numEvenStrengthLines[0], positions: forwardPositions)
                            
                            // Defense lineups
                            evenStrengthLineups(numLines: numEvenStrengthLines[1], positions: defensePositions)
                            
                            // Goalie lineups
                            evenStrengthLineups(numLines: numEvenStrengthLines[2], positions: goaliePositions)
                        }
                        .padding(.top, Spacing.spacingExtraSmall)
                    } else {
                        // Powerplay, penalty kill, or overtime lineups
                        specialTeamsLineups(lineupType: selectedLineupType)
                    }
                } else {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                    
                Spacer()
            }
            .padding(.horizontal, Spacing.spacingExtraSmall)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .appBackgroundStyle()
            .onAppear {
                // Set the initial team
                selectedTeamIndex = teamIndex
            }
            .onChange(of: selectedTeamIndex) { newIndex in
                isLineupLoaded = false
                
                // Fetch the teams
                viewModel.fetchTeams() { teamsFetched in
                    if teamsFetched, viewModel.teams.indices.contains(newIndex) {
                        // Fetch the team lineup
                        viewModel.fetchTeamLineup(teamID: viewModel.teams[newIndex].teamID) { lineupFetched in
                            isLineupLoaded = lineupFetched
                        }
                    }
                }
            }
            .navigationDestination(isPresented: $showPlayerLineupSwapView, destination: {
                // Navigate to Player Lineup Swap view when back button is clicked
                PlayerLineupSwapView(teamIndex: $selectedTeamIndex, playerID: $playerID, playerName: $playerName, playerPosition: $playerPosition, playerLineNumber: $playerLineNumber, lineupType: $selectedLineupType)
                    .environmentObject(userInfo)
                    .environmentObject(simulationState)
                    .navigationBarHidden(true)
            })
            .navigationDestination(isPresented: $returnToMainSimView, destination: {
                // Navigate to Main Sim page when back button is clicked
                MainSimView()
                    .environmentObject(userInfo)
                    .environmentObject(simulationState)
                    .navigationBarHidden(true)
            })
        }
    }
    
    // View of the picker of lineup type
    @ViewBuilder
    private func lineupTypePicker() -> some View {
        HStack {
            ForEach(LineupType.allCases) { type in
                Button(action: {
                    selectedLineupType = type
                }) {
                    Text(type.rawValue)
                        .frame(maxWidth: .infinity)
                        .padding(Spacing.spacingExtraSmall)
                        .font(.footnote)
                        .background(selectedLineupType == type ? Color.white : Color.black)
                        .foregroundColor(selectedLineupType == type ? Color.black : Color.white)
                        .appTextStyle()
                        .appButtonStyle()
                }
            }
        }
    }
    
    // View of the lineup block
    @ViewBuilder
    private func lineupBlock(lineupType: LineupType, lineNumber: Int, position: String, positionIndex: Int?) -> some View {
        let playerDetails = viewModel.playerDetails(lineupType: lineupType, lineNumber: lineNumber, position: position, positionIndex: positionIndex)
        let id = playerDetails.first
        let name = playerDetails.last
        Button {
            playerID = Int("\(id ?? "")") ?? 0
            playerName = name ?? ""
            playerPosition = position
            playerLineNumber = lineNumber
            showPlayerLineupSwapView = true
        } label: {
            Text(name?.uppercased() ?? "")
                .appTextStyle()
                .font(.system(size: 11))
                .frame(width: blockWidth, height: blockHeight, alignment: .center)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .padding(.horizontal, Spacing.spacingSmall)
        }
    }
    
    // View of the even strength position lineups
    @ViewBuilder
    private func evenStrengthLineups(numLines: Int, positions: [String]) -> some View {
        VStack {
            HStack {
                ForEach(positions, id: \.self) { position in
                    Text(position)
                        .appTextStyle()
                        .font(.footnote)
                        .frame(width: blockWidth, alignment: .center)
                        .padding(.horizontal, Spacing.spacingSmall)
                }
            }
            .padding(.top, Spacing.spacingExtraSmall)
            
            ForEach(1...numLines, id: \.self) { lineNumber in
                HStack {
                    ForEach(positions, id: \.self) { position in
                        lineupBlock(lineupType: .evenStrength, lineNumber: lineNumber, position: position, positionIndex: nil)
                    }
                    .appButtonStyle()
                }
            }
        }
    }
    
    // View of the special teams lineups
    @ViewBuilder
    private func specialTeamsLineups(lineupType: LineupType) -> some View {
        VStack {
            ForEach(1...numSpecialTeamsLines, id: \.self) { lineNumber in
                VStack {
                    Text(lineupType.rawValue + " " + LocalizedText.line.localizedString + " " + "\(lineNumber)")
                        .appTextStyle()
                        .font(.footnote)
                        .frame(width: blockWidth, alignment: .center)
                        .padding(.horizontal, Spacing.spacingSmall)
                    
                    VStack {
                        specialTeamsForwardLine(lineupType: lineupType, lineNumber: lineNumber)
                        specialTeamsDefenseLine(lineupType: lineupType, lineNumber: lineNumber)
                    }
                }
            }
            .padding(.top, Spacing.spacingExtraSmall)
        }
        .padding(.top, Spacing.spacingExtraSmall)
    }
    
    // View of the special teams forwards
    @ViewBuilder
    private func specialTeamsForwardLine(lineupType: LineupType, lineNumber: Int) -> some View {
        let numForwards = lineupType == .powerplay ? 3 : 2
        
        HStack {
            ForEach(0..<numForwards, id: \.self) { forwardIndex in
                lineupBlock(lineupType: lineupType, lineNumber: lineNumber, position: PositionType.forwards.rawValue, positionIndex: forwardIndex)
            }
            .appButtonStyle()
        }
    }
    
    // View of the special teams defensemen
    @ViewBuilder
    private func specialTeamsDefenseLine(lineupType: LineupType, lineNumber: Int) -> some View {
        let numForwards = lineupType == .powerplay ? 3 : 2
        let numDefensemen = lineupType == .overtime ? 1 : 2
        
        HStack {
            ForEach(numForwards..<numForwards + numDefensemen, id: \.self) { defenseIndex in
                lineupBlock(lineupType: lineupType, lineNumber: lineNumber, position: PositionType.defensemen.rawValue, positionIndex: defenseIndex)
            }
            .appButtonStyle()
        }
    }
}
