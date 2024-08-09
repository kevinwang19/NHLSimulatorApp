//
//  PlayerStatsView.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-08-05.
//

import SDWebImageSwiftUI
import SwiftUI

struct PlayerStatsView: View {
    @EnvironmentObject var userInfo: UserInfo
    @EnvironmentObject var simulationState: SimulationState
    @ObservedObject var viewModel: PlayerStatsViewModel = PlayerStatsViewModel()
    @Binding var teamIndex: Int
    @State private var selectedTeamIndex: Int = 0
    @State private var showDropdown: Bool = false
    @State private var isDisabled: Bool = false
    @State private var returnToMainSimView: Bool = false
    @State private var isStatsLoaded: Bool = false
    @State private var selectedPlayerType: PlayerType = .skaters
    @State private var selectedPositionType: PositionType = .all
    @State private var showPlayerDetailsView: Bool = false
    @State private var selectedPlayerID: Int = 0
    private var positionPickerTypes: [PositionType] = [.all, .forwards, .centers, .leftWingers, .rightWingers, .defensemen]
    
    init(teamIndex: Binding<Int>) {
        self._teamIndex = teamIndex
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if isStatsLoaded {
                    // Title and back button
                    ScreenHeaderView(returnToPreviousView: $returnToMainSimView)
                    
                    HStack {
                        // Drop down menu of all teams
                        TeamDropDownMenuView(selectedTeamIndex: $selectedTeamIndex, showDropdown: $showDropdown, teams: viewModel.teams, isDisabled: $isDisabled)
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
                    
                    playerTypePicker()
                        .padding(.top, Spacing.spacingSmall)
                    
                    // Skater position picker
                    if selectedPlayerType == .skaters {
                        positionTypePicker()
                            .padding(.top, Spacing.spacingSmall)
                    }
                    
                    // Player stats grid view if there are stats
                    if viewModel.simSkaterStats.count == 0 {
                        Text(LocalizedText.noStats.localizedString)
                            .appTextStyle()
                            .font(.footnote)
                            .padding(.top, Spacing.spacingExtraLarge)
                    } else {
                        PlayerSortableStatsGridView(viewModel: viewModel, selectedPlayerType: $selectedPlayerType, showPlayerDetailsView: $showPlayerDetailsView, selectedPlayerID: $selectedPlayerID)
                    }
                    
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
                // Set the initial team
                selectedTeamIndex = teamIndex
            }
            .onChange(of: selectedTeamIndex) { newIndex in
                isStatsLoaded = false
                viewModel.simSkaterStats = []
                viewModel.simGoalieStats = []
                selectedPositionType = .all
                
                // Fetch the teams
                viewModel.fetchTeams() { teamsFetched in
                    // Fetch the player stats of the selected team
                    if teamsFetched, viewModel.teams.indices.contains(newIndex) {
                        teamIndex = newIndex
                        
                        viewModel.fetchPlayerSimStats(simulationID: userInfo.simulationID, teamID: viewModel.teams[teamIndex].teamID) { statsFetched in
                            isStatsLoaded = statsFetched
                        }
                    }
                }
            }
            .onChange(of: selectedPositionType) { newPosition in
                // Fetch the player stats of the filtered position
                viewModel.fetchSkaterPositionSimStats(simulationID: userInfo.simulationID, teamID: viewModel.teams[selectedTeamIndex].teamID, position: newPosition.rawValue)
            }
            .navigationDestination(isPresented: $returnToMainSimView, destination: {
                // Navigate to Main Sim page when back button is clicked
                MainSimView()
                    .environmentObject(userInfo)
                    .environmentObject(simulationState)
                    .navigationBarHidden(true)
            })
            .navigationDestination(isPresented: $showPlayerDetailsView, destination: {
                // Navigate to Main Sim page when back button is clicked
                PlayerDetailsView(selectedPlayerID: $selectedPlayerID, teamIndex: $teamIndex)
                    .environmentObject(userInfo)
                    .environmentObject(simulationState)
                    .navigationBarHidden(true)
            })
        }
    }
    
    // View of the picker of skater or goalie stats
    @ViewBuilder
    private func playerTypePicker() -> some View {
        HStack {
            ForEach(PlayerType.allCases) { type in
                Button(action: {
                    selectedPlayerType = type
                }) {
                    Text(type.localizedStringKey)
                        .frame(maxWidth: .infinity)
                        .padding(Spacing.spacingExtraSmall)
                        .font(.footnote)
                        .background(selectedPlayerType == type ? Color.white : Color.black)
                        .foregroundColor(selectedPlayerType == type ? Color.black : Color.white)
                        .appTextStyle()
                        .appButtonStyle()
                }
            }
        }
    }
    
    // View of the picker of the different skater positions
    @ViewBuilder
    private func positionTypePicker() -> some View {
        HStack {
            ForEach(positionPickerTypes) { type in
                Button(action: {
                    selectedPositionType = type
                }) {
                    let typeText = type == .all ? PositionType.all.localizedString : type.rawValue
                    Text(typeText)
                        .frame(maxWidth: .infinity)
                        .padding(Spacing.spacingExtraSmall)
                        .font(.caption2)
                        .background(selectedPositionType == type ? Color.white : Color.black)
                        .foregroundColor(selectedPositionType == type ? Color.black : Color.white)
                        .appTextStyle()
                        .appButtonStyle()
                }
            }
        }
    }
}
