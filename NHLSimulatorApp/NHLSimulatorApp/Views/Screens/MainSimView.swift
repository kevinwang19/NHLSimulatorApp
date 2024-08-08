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
    @State private var showStandingsView: Bool = false
    @State private var showStatsView: Bool = false
    @State private var showRostersView: Bool = false
    @State private var showLineupsView: Bool = false
    @State private var returnToLaunchView: Bool = false
    
    var body: some View {
        if isSimulationLoaded {
            NavigationStack {
                VStack {
                    // Title and back button
                    ScreenHeaderView(returnToPreviousView: $returnToLaunchView)
                    
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
                            .frame(maxHeight: .infinity)
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
                                    teamBlockView(teamTitle: viewModel.teamTitle(date: selectedDate, teamID: viewModel.teams[selectedTeamIndex].teamID, teamAbbrev: viewModel.teams[selectedTeamIndex].abbrev), teamLogo: viewModel.teams[selectedTeamIndex].logo, teamRecord: viewModel.teamRecord(teamStat: viewModel.simTeamStat))
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
                .navigationDestination(isPresented: $returnToLaunchView, destination: {
                    // Navigate to Team Standings page when it's button is clicked
                    LaunchView()
                        .navigationBarHidden(true)
                })
                .navigationDestination(isPresented: $showStandingsView, destination: {
                    // Navigate to Launch page when it's button is clicked
                    TeamStandingsView()
                        .environmentObject(userInfo)
                        .environmentObject(simulationState)
                        .navigationBarHidden(true)
                })
                .navigationDestination(isPresented: $showStatsView, destination: {
                    // Navigate to Players Stats page when it's button is clicked
                    PlayerStatsView(teamIndex: $selectedTeamIndex)
                        .environmentObject(userInfo)
                        .environmentObject(simulationState)
                        .navigationBarHidden(true)
                })
                .navigationDestination(isPresented: $showRostersView, destination: {
                    // Navigate to Edit Rosters page when it's button is clicked
                    EditRostersView()
                        .environmentObject(userInfo)
                        .environmentObject(simulationState)
                        .navigationBarHidden(true)
                })
                .navigationDestination(isPresented: $showLineupsView, destination: {
                    // Navigate to Edit Lineups page when it's button is clicked
                    EditLineupsView()
                        .environmentObject(userInfo)
                        .environmentObject(simulationState)
                        .navigationBarHidden(true)
                })
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
                            viewModel.setupCoreData() { dataSaved in
                                if dataSaved {
                                    viewModel.generateSimulation(userInfo: userInfo) { simulationGenerated in
                                        isSimulationLoaded = simulationGenerated
                                    }
                                }
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
    
    // View of the selected team details and their opponent details
    @ViewBuilder
    private func matchupView(matchupGame: Schedule) -> some View {
        if isMatchupLoaded {
            HStack {
                teamBlockView(teamTitle: viewModel.teamTitle(date: selectedDate, teamID: matchupGame.awayTeamID, teamAbbrev: matchupGame.awayTeamAbbrev), teamLogo: matchupGame.awayTeamLogo, teamRecord: (viewModel.simTeamStat?.teamID == matchupGame.awayTeamID) ? viewModel.teamRecord(teamStat: viewModel.simTeamStat) : viewModel.teamRecord(teamStat: viewModel.simOpponentStat))
                    .padding(.leading, Spacing.spacingExtraSmall)
                
                Text(Symbols.atSymbol.rawValue)
                    .appTextStyle()
                    .font(.caption)
                    .padding(.top, Spacing.spacingExtraSmall)
                
                teamBlockView(teamTitle: viewModel.teamTitle(date: selectedDate, teamID: matchupGame.homeTeamID, teamAbbrev: matchupGame.homeTeamAbbrev), teamLogo: matchupGame.homeTeamLogo, teamRecord: (viewModel.simTeamStat?.teamID == matchupGame.homeTeamID) ? viewModel.teamRecord(teamStat: viewModel.simTeamStat) : viewModel.teamRecord(teamStat: viewModel.simOpponentStat))
                    .padding(.trailing, Spacing.spacingExtraSmall)
            }
        } else {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    // View of the team name, logo, and record
    @ViewBuilder
    private func teamBlockView(teamTitle: String, teamLogo: String, teamRecord: String) -> some View {
        if isMatchupLoaded {
            VStack {
                Text(teamTitle)
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
    
    // View of the button used for simulating games
    @ViewBuilder
    private func simulateButton() -> some View {
        Button {
            isInteractionDisabled = true
            
            guard let daysToSimulate = viewModel.calendar.dateComponents([.day], from: currentDate, to: selectedDate).day else {
                isInteractionDisabled = false
                return
            }
            
            if daysToSimulate <= 0 {
                isInteractionDisabled = false
                return
            }
            
            simulateDay(simulatedDays: 0, daysToSimulate: daysToSimulate)
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
    
    // View of the buttons at the bottom of the screen
    @ViewBuilder
    private func footerButtons() -> some View {
        HStack {
            // Button for showing the league standings
            Button {
                simulationState.isNewSim = false
                showStandingsView = true
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
                simulationState.isNewSim = false
                showStatsView = true
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
                simulationState.isNewSim = false
                showRostersView = true
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
                simulationState.isNewSim = false
                showLineupsView = true
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
    
    // Simulate each day and show the results
    private func simulateDay(simulatedDays: Int, daysToSimulate: Int) {
        if simulatedDays >= daysToSimulate {
            isInteractionDisabled = false
            return
        }
            
        guard let nextDay = viewModel.calendar.date(byAdding: .day, value: 1, to: currentDate) else {
            isInteractionDisabled = false
            return
        }
            
        let stringSimulateDate = viewModel.dateFormatter.string(from: nextDay)
            
        viewModel.simulate(simulationID: userInfo.simulationID, simulateDate: stringSimulateDate) { simulated in
            if simulated {
                currentDate = nextDay
                selectedDate = selectedDate.addingTimeInterval(1)
                simulateDay(simulatedDays: simulatedDays + 1, daysToSimulate: daysToSimulate)
            } else {
                isInteractionDisabled = false
            }
        }
    }
}

struct MainSimView_Previews: PreviewProvider {
    static var previews: some View {
        MainSimView().environmentObject(UserInfo())
    }
}
