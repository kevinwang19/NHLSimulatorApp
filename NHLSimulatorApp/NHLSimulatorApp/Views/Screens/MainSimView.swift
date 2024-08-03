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
    @State private var currentDate: Date = Date()
    @State private var selectedDate: Date = Date()
    @State private var isSimulationLoaded: Bool = false
    @State private var isMatchupLoaded: Bool = false
    @State private var isInteractionDisabled = false
    
    var body: some View {
        if isSimulationLoaded {
            NavigationStack {
                VStack {
                    // Title
                    Text(LocalizedStringKey(LocalizedText.nhlSimulator.rawValue))
                        .appTextStyle()
                        .font(.headline)
                        .padding(.top, Spacing.spacingExtraSmall)
                    
                    HStack {
                        // Drop down menu of all teams
                        TeamDropDownMenuView(selectedTeamIndex: $selectedTeamIndex, showDropdown: $showDropdown, teams: viewModel.teams, isDisabled: $isInteractionDisabled)
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
                    
                    // Calendar of the selected team's matchups
                    if viewModel.teams.indices.contains(selectedTeamIndex) {
                        CalendarView(viewModel: viewModel, currentDate: $currentDate, selectedDate: $selectedDate, teamID: $viewModel.teams[selectedTeamIndex].teamID, isDisabled: $isInteractionDisabled)
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
                        .frame(maxWidth: .infinity, minHeight: 75, maxHeight: .infinity)
                        .appButtonStyle()
                        
                        simulateButton()
                            .disabled(isInteractionDisabled)
                    }
                    
                    footerButtons()
                    
                    Spacer()
                }
                .padding(.horizontal, Spacing.spacingExtraSmall)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .appBackgroundStyle()
                .onChange(of: selectedDate) { newSelectedDate in
                    isMatchupLoaded = false
                    let stringDate = viewModel.dateFormatter.string(from: newSelectedDate)
                    
                    // Fetch the matchup of the selected date
                    viewModel.fetchTeamDaySchedule(teamID: viewModel.teams[selectedTeamIndex].teamID, date: stringDate) { scheduleFetched in
                        var opponentID: Int? = nil
                        if scheduleFetched, let matchupGame = viewModel.matchupGame {
                            opponentID = (viewModel.teams[selectedTeamIndex].teamID == matchupGame.awayTeamID ? matchupGame.homeTeamID : matchupGame.awayTeamID)
                        }
                        
                        // Fetch the record of the team
                        viewModel.fetchTeamStats(simulationID: userInfo.simulationID, teamID: viewModel.teams[selectedTeamIndex].teamID, opponentID: opponentID) { statsFetched in
                            isMatchupLoaded = statsFetched
                        }
                    }
                }
            }
        } else {
            // Show loading screen while the simulation is being created or loaded, set the team picker as the user's selected team
            VStack {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                
                ProgressView(LocalizedStringKey(LocalizedText.simulationSetupMessage.rawValue))
                    .appTextStyle()
                    .task {
                        selectedTeamIndex = userInfo.favTeamIndex
                        
                        if simulationState.isNewSim {
                            viewModel.generateSimulation(userInfo: userInfo) { simulationGenerated in
                                isSimulationLoaded = simulationGenerated
                            }
                        } else {
                            isSimulationLoaded = true
                        }
                    }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .appBackgroundStyle()
        }
    }
    
    @ViewBuilder
    private func matchupView(matchupGame: Schedule) -> some View {
        if isMatchupLoaded {
            HStack {
                teamBlockView(teamAbbrev: matchupGame.awayTeamAbbrev, teamLogo: matchupGame.awayTeamLogo, teamRecord: (viewModel.simTeamStat?.teamID == matchupGame.awayTeamID) ? viewModel.teamRecord(teamStat: viewModel.simTeamStat) : viewModel.teamRecord(teamStat: viewModel.simOpponentStat))
                    .padding(.leading, Spacing.spacingExtraSmall)
                
                Text(Symbols.atSymbol.rawValue)
                    .appTextStyle()
                    .font(.caption)
                    .padding(.top, Spacing.spacingExtraSmall)
                
                teamBlockView(teamAbbrev: matchupGame.homeTeamAbbrev, teamLogo: matchupGame.homeTeamLogo, teamRecord: (viewModel.simTeamStat?.teamID == matchupGame.homeTeamID) ? viewModel.teamRecord(teamStat: viewModel.simTeamStat) : viewModel.teamRecord(teamStat: viewModel.simOpponentStat))
                    .padding(.trailing, Spacing.spacingExtraSmall)
            }
        } else {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    @ViewBuilder
    private func teamBlockView(teamAbbrev: String, teamLogo: String, teamRecord: String) -> some View {
        if isMatchupLoaded {
            VStack {
                Text(teamAbbrev)
                    .appTextStyle()
                    .font(.caption)
                    .padding(.top, Spacing.spacingExtraSmall)
                
                let url = URL(string: teamLogo)
                WebImage(url: url)
                    .resizable()
                    .scaledToFit()
                    .frame(minHeight: 15, maxHeight: 75)
                
                Text(teamRecord)
                    .appTextStyle()
                    .font(.footnote)
                    .padding(.bottom, Spacing.spacingExtraSmall)
            }
        } else {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    @ViewBuilder
    private func simulateButton() -> some View {
        Button {
            isInteractionDisabled = true
            let stringSimulateDate = viewModel.dateFormatter.string(from: selectedDate)
            
            if selectedDate <= currentDate {
                isInteractionDisabled = false
                return
            }

            viewModel.simulate(simulationID: userInfo.simulationID, simulateDate: stringSimulateDate) { simulated in
                guard let daysToSimulate = viewModel.calendar.dateComponents([.day], from: currentDate, to: selectedDate).day else {
                    isInteractionDisabled = false
                    return
                }
                
                if daysToSimulate <= 0 {
                    isInteractionDisabled = false
                    return
                }
                
                if simulated {
                    for _ in 1...daysToSimulate {
                        guard let nextDay = viewModel.calendar.date(byAdding: .day, value: 1, to: currentDate) else {
                            isInteractionDisabled = false
                            return
                        }
                        
                        currentDate = nextDay
                        selectedDate = selectedDate.addingTimeInterval(1)
                    }
                    
                    isInteractionDisabled = false
                }
            }
        } label: {
            if isInteractionDisabled {
                VStack {
                    Text(LocalizedStringKey(LocalizedText.simulating.rawValue))
                        .appTextStyle()
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                }
                .padding(Spacing.spacingExtraSmall)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                let selectedDateString = viewModel.dateFormatter.string(from: selectedDate)
                Text(String(format: NSLocalizedString(LocalizedText.simulateTo.rawValue, comment: "")) + selectedDateString)
                    .appTextStyle()
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(Spacing.spacingExtraSmall)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
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
    }
}

struct MainSimView_Previews: PreviewProvider {
    static var previews: some View {
        MainSimView().environmentObject(UserInfo())
    }
}
