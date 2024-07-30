//
//  MainSimView.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-07-09.
//

import SDWebImageSwiftUI
import SwiftUI

struct MainSimView: View {
    @EnvironmentObject var userInfo: UserInfo
    @EnvironmentObject var simulationState: SimulationState
    @ObservedObject var viewModel: MainSimViewModel = MainSimViewModel()
    @State private var selectedTeamIndex: Int = 0
    @State private var showDropdown: Bool = false
    @State private var selectedDate: Date = Date()
    @State private var isSimulationLoaded: Bool = false
    
    var body: some View {
        if isSimulationLoaded {
            NavigationStack {
                VStack {
                    // Title
                    Text(LocalizedStringKey(LocalizedText.nhlSimulator.rawValue))
                        .appTextStyle()
                        .font(.headline)
                    
                    HStack {
                        // Drop down menu of all teams
                        TeamDropDownMenuView(selectedTeamIndex: $selectedTeamIndex, showDropdown: $showDropdown, teams: viewModel.teams)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Selected team logo
                        if viewModel.teams.indices.contains(selectedTeamIndex) {
                            let url = URL(string: viewModel.teams[selectedTeamIndex].logo)
                            WebImage(url: url)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 75, height: 75)
                                .padding(.trailing, Spacing.spacingSmall)
                        } else {
                            Rectangle()
                                .fill(.clear)
                                .scaledToFit()
                                .frame(width: 75, height: 75)
                                .padding(.trailing, Spacing.spacingSmall)
                        }
                    }
                    .zIndex(1)
                    
                    // Calendar of the selected team's matchups
                    if viewModel.teams.indices.contains(selectedTeamIndex) {
                        CalendarView(viewModel: viewModel, selectedDate: $selectedDate, teamID: $viewModel.teams[selectedTeamIndex].teamID)
                            .environmentObject(userInfo)
                            .zIndex(0)
                            .overlay(
                                Color.white.opacity(showDropdown ? 0.15 : 0.0)
                                    .cornerRadius(10)
                            )
                    } else {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                            .frame(height: 430)
                    }
                    
                    HStack {
                        VStack {
                            if let matchupGame = viewModel.matchupGame {
                                matchupView(matchupGame: matchupGame)
                            } else {
                                if viewModel.teams.indices.contains(selectedTeamIndex) {
                                    teamBlockView(teamAbbrev: viewModel.teams[selectedTeamIndex].abbrev, teamLogo: viewModel.teams[selectedTeamIndex].logo, teamRecord: viewModel.teamRecord(teamStat: viewModel.simTeamStat))
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .appButtonStyle()
                        
                        simulateButton()
                    }
                    .padding(.top, Spacing.spacingExtraSmall)
                    
                    Spacer()
                    
                    footerButtons()
                }
                .padding(Spacing.spacingExtraSmall)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .appBackgroundStyle()
                .onAppear {
                    //selectedDate = selectedDate.addingTimeInterval(1)
                }
                .onChange(of: selectedDate) { newSelectedDate in
                    let stringDate = viewModel.dateFormatter.string(from: newSelectedDate)
                    viewModel.fetchTeamDaySchedule(teamID: viewModel.teams[selectedTeamIndex].teamID, date: stringDate) { success in
                        var opponentID: Int? = nil
                        if success, let matchupGame = viewModel.matchupGame {
                            opponentID = (viewModel.teams[selectedTeamIndex].teamID == matchupGame.awayTeamID ? matchupGame.homeTeamID : matchupGame.awayTeamID)
                        }
                        viewModel.fetchTeamStats(simulationID: userInfo.simulationID, teamID: viewModel.teams[selectedTeamIndex].teamID, opponentID: opponentID)
                    }
                }
            }
        } else {
            // Show loading screen while the simulation is being created or loaded, set the team picker as the user's selected team
            ProgressView(LocalizedStringKey(LocalizedText.simulationSetupMessage.rawValue))
                .appTextStyle()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .appBackgroundStyle()
                .task {
                    selectedTeamIndex = userInfo.favTeamIndex
                    
                    if simulationState.isNewSim {
                        viewModel.generateSimulation(userInfo: userInfo) { success in
                            isSimulationLoaded = success
                        }
                    } else {
                        isSimulationLoaded = true
                    }
                }
        }
    }
    
    @ViewBuilder
    private func matchupView(matchupGame: Schedule) -> some View {
        HStack {
            teamBlockView(teamAbbrev: matchupGame.awayTeamAbbrev, teamLogo: matchupGame.awayTeamLogo, teamRecord: (viewModel.simTeamStat?.teamID == matchupGame.awayTeamID) ? viewModel.teamRecord(teamStat: viewModel.simTeamStat) : viewModel.teamRecord(teamStat: viewModel.simOpponentStat))
            
            Text(Symbols.atSymbol.rawValue)
                .appTextStyle()
                .font(.caption)
                .padding(.top, Spacing.spacingExtraSmall)
            
            teamBlockView(teamAbbrev: matchupGame.homeTeamAbbrev, teamLogo: matchupGame.homeTeamLogo, teamRecord: (viewModel.simTeamStat?.teamID == matchupGame.homeTeamID) ? viewModel.teamRecord(teamStat: viewModel.simTeamStat) : viewModel.teamRecord(teamStat: viewModel.simOpponentStat))
        }
    }

    @ViewBuilder
    private func teamBlockView(teamAbbrev: String, teamLogo: String, teamRecord: String) -> some View {
        VStack {
            Text(teamAbbrev)
                .appTextStyle()
                .font(.caption)
                .padding(.top, Spacing.spacingExtraSmall)
            
            let url = URL(string: teamLogo)
            WebImage(url: url)
                .resizable()
                .scaledToFit()
            
            Text(teamRecord)
                .appTextStyle()
                .font(.footnote)
                .padding(.bottom, Spacing.spacingExtraSmall)
        }
    }
    
    @ViewBuilder
    private func simulateButton() -> some View {
        Button {
            // Simulation action
        } label: {
            let selectedDateString = viewModel.dateFormatter.string(from: selectedDate)
            Text(String(format: NSLocalizedString(LocalizedText.simulateTo.rawValue, comment: "")) + selectedDateString)
                .appTextStyle()
                .font(.headline)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(Spacing.spacingExtraSmall)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .appButtonStyle()
    }
    
    @ViewBuilder
    private func footerButtons() -> some View {
        HStack {
            // Button for showing the league standings
            Button {
                
            } label: {
                Text(LocalizedStringKey(LocalizedText.teamStandings.rawValue))
                    .appTextStyle()
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity)
                    .padding(Spacing.spacingExtraSmall)
            }
            .appButtonStyle()
            
            // Button for showing the player stats
            Button {
                
            } label: {
                Text(LocalizedStringKey(LocalizedText.playerStats.rawValue))
                    .appTextStyle()
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity)
                    .padding(Spacing.spacingExtraSmall)
            }
            .appButtonStyle()
            
            // Button for showing and managing the team's roster
            Button {
                
            } label: {
                Text(LocalizedStringKey(LocalizedText.editRosters.rawValue))
                    .appTextStyle()
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity)
                    .padding(Spacing.spacingExtraSmall)
            }
            .appButtonStyle()
            
            // Button for showing and managing the team's lines
            Button {
                
            } label: {
                Text(LocalizedStringKey(LocalizedText.editLineups.rawValue))
                    .appTextStyle()
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity)
                    .padding(Spacing.spacingExtraSmall)
            }
            .appButtonStyle()
        }
        .padding(.top, Spacing.spacingExtraSmall)
    }
}

struct MainSimView_Previews: PreviewProvider {
    static var previews: some View {
        MainSimView().environmentObject(UserInfo())
    }
}
