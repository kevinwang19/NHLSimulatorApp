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
    @State private var isGeneratingPlayoffs = false
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
                    ScreenHeaderView(returnToPreviousView: $returnToLaunchView, backButtonDisabled: $isInteractionDisabled)
                    
                    HStack {
                        // Drop down menu of all teams
                        TeamDropDownMenuView(selectedTeamIndex: $selectedTeamIndex, showDropdown: $showDropdown, teams: viewModel.teams, maxTeamsDisplayed: 5, isDisabled: $isInteractionDisabled)
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
                            if userInfo.seasonComplete, let lastSeasonGameDate = viewModel.dateFormatter.date(from: viewModel.lastRound4GameDate), selectedDate > lastSeasonGameDate {
                                playoffWinnerView()
                            } else if userInfo.isPlayoffs, let lastGameDate = viewModel.dateFormatter.date(from: viewModel.lastGameDate), selectedDate > lastGameDate, let playoffMatchupGame = viewModel.playoffMatchupGame {
                                playoffMatchupView(playoffMatchupGame: playoffMatchupGame)
                            } else if let matchupGame = viewModel.matchupGame {
                                matchupView(matchupGame: matchupGame)
                            } else {
                                if viewModel.teams.indices.contains(selectedTeamIndex), let lastGameDate = viewModel.dateFormatter.date(from: viewModel.lastGameDate) {
                                    let teamRecord = selectedDate > lastGameDate ? viewModel.teamPlayoffRecord(teamPlayoffStat: viewModel.simPlayoffTeamStat) : viewModel.teamRecord(teamStat: viewModel.simTeamStat)
                                    
                                    teamBlockView(teamTitle: viewModel.teamTitle(date: selectedDate, teamID: viewModel.teams[selectedTeamIndex].teamID, teamAbbrev: viewModel.teams[selectedTeamIndex].abbrev), teamLogo: viewModel.teams[selectedTeamIndex].logo, teamRecord: teamRecord)
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
                    if !isInteractionDisabled {
                        isMatchupLoaded = false
                        let stringDate = viewModel.dateFormatter.string(from: newSelectedDate)
                        
                        if userInfo.isPlayoffs {
                            // Fetch the playoff matchup of the selected date
                            viewModel.fetchTeamDayPlayoffSchedule(simulationID: userInfo.simulationID, teamID: viewModel.teams[selectedTeamIndex].teamID, date: stringDate) { scheduleFetched in
                                var opponentID: Int? = nil
                                if scheduleFetched, let playoffMatchupGame = viewModel.playoffMatchupGame {
                                    opponentID = (viewModel.teams[selectedTeamIndex].teamID == playoffMatchupGame.awayTeamID ? playoffMatchupGame.homeTeamID : playoffMatchupGame.awayTeamID)
                                }
                                
                                // Fetch the playoff record of the team
                                viewModel.fetchTeamPlayoffStats(simulationID: userInfo.simulationID, teamID: viewModel.teams[selectedTeamIndex].teamID, opponentID: opponentID) { _ in
                                }
                            }
                        }
                        
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
                .onChange(of: currentDate) { newCurrentDate in
                    // Fetch the last game of the regular season
                    viewModel.fetchLastGame(season: userInfo.season) { gameFetched in
                        // If the current day is 1 day after the last game of the regular season, create round 1 playoff matchups
                        if gameFetched, !userInfo.isPlayoffs,
                           let lastGameDate = viewModel.dateFormatter.date(from: viewModel.lastGameDate),
                           let lastGameFollowingDate = viewModel.calendar.date(byAdding: .day, value: 1, to: lastGameDate),
                           viewModel.calendar.startOfDay(for: newCurrentDate) == viewModel.calendar.startOfDay(for: lastGameFollowingDate) {
                                
                            isGeneratingPlayoffs = true
                            isInteractionDisabled = true
                            viewModel.createPlayoffRound1Schedules(simulationID: userInfo.simulationID) { scheduleCreated in
                                isGeneratingPlayoffs = !scheduleCreated
                                isInteractionDisabled = !scheduleCreated
                                userInfo.isPlayoffs = true
                                selectedDate = selectedDate.addingTimeInterval(1)
                            }
                        }
                    }
                        
                    isMatchupLoaded = false
                    let stringDate = viewModel.dateFormatter.string(from: newCurrentDate)
                    
                    if userInfo.isPlayoffs {
                        // Delete extra playoff games
                        viewModel.deleteExtraPlayoffSchedules(simulationID: userInfo.simulationID, isRound2: userInfo.playoffRound1Complete, isRound3: userInfo.playoffRound2Complete, isRound4: userInfo.playoffRound3Complete) { _ in }
                        
                        if !userInfo.playoffRound1Complete {
                            // Fetch the last game of round 1 of the playoffs
                            viewModel.fetchRound1LastGame(simulationID: userInfo.simulationID) { gameFetched in
                                // If the current day is 1 day after the last game of round 1, create round 2 matchups
                                if gameFetched, let lastRound1GameDate = viewModel.dateFormatter.date(from: viewModel.lastRound1GameDate),
                                   let lastRound1GameFollowingDate = viewModel.calendar.date(byAdding: .day, value: 1, to: lastRound1GameDate),
                                   viewModel.calendar.startOfDay(for: newCurrentDate) == viewModel.calendar.startOfDay(for: lastRound1GameFollowingDate) {
                                    
                                    isGeneratingPlayoffs = true
                                    isInteractionDisabled = true
                                    viewModel.createPlayoffRound2Schedules(simulationID: userInfo.simulationID) { scheduleCreated in
                                        isGeneratingPlayoffs = !scheduleCreated
                                        isInteractionDisabled = !scheduleCreated
                                        userInfo.playoffRound1Complete = true
                                        selectedDate = selectedDate.addingTimeInterval(1)
                                    }
                                }
                            }
                        }
                        
                        if !userInfo.playoffRound2Complete {
                            // Fetch the last game of round 2 of the playoffs
                            viewModel.fetchRound2LastGame(simulationID: userInfo.simulationID) { gameFetched in
                                // If the current day is 1 day after the last game of round 2, create round 3 matchups
                                if gameFetched, let lastRound2GameDate = viewModel.dateFormatter.date(from: viewModel.lastRound2GameDate),
                                   let lastRound2GameFollowingDate = viewModel.calendar.date(byAdding: .day, value: 1, to: lastRound2GameDate),
                                   viewModel.calendar.startOfDay(for: newCurrentDate) == viewModel.calendar.startOfDay(for: lastRound2GameFollowingDate) {
                                    
                                    isGeneratingPlayoffs = true
                                    isInteractionDisabled = true
                                    viewModel.createPlayoffRound3Schedules(simulationID: userInfo.simulationID) { scheduleCreated in
                                        isGeneratingPlayoffs = !scheduleCreated
                                        isInteractionDisabled = !scheduleCreated
                                        userInfo.playoffRound2Complete = true
                                        selectedDate = selectedDate.addingTimeInterval(1)
                                    }
                                }
                            }
                        }
                        
                        if !userInfo.playoffRound3Complete {
                            // Fetch the last game of round 3 of the playoffs
                            viewModel.fetchRound3LastGame(simulationID: userInfo.simulationID) { gameFetched in
                                // If the current day is 1 day after the last game of round 3, create round 4 matchups
                                if gameFetched, let lastRound3GameDate = viewModel.dateFormatter.date(from: viewModel.lastRound3GameDate),
                                   let lastRound3GameFollowingDate = viewModel.calendar.date(byAdding: .day, value: 1, to: lastRound3GameDate),
                                   viewModel.calendar.startOfDay(for: newCurrentDate) == viewModel.calendar.startOfDay(for: lastRound3GameFollowingDate) {
                                    
                                    isGeneratingPlayoffs = true
                                    isInteractionDisabled = true
                                    viewModel.createPlayoffRound4Schedules(simulationID: userInfo.simulationID) { scheduleCreated in
                                        isGeneratingPlayoffs = !scheduleCreated
                                        isInteractionDisabled = !scheduleCreated
                                        userInfo.playoffRound3Complete = true
                                        selectedDate = selectedDate.addingTimeInterval(1)
                                    }
                                }
                            }
                        }
                        
                        // Fetch the last game of the playoffs
                        viewModel.fetchRound4LastGame(simulationID: userInfo.simulationID) { gameFetched in
                            // If the current day is 1 day after the last game of the finals, update season as finished
                            if gameFetched, !userInfo.seasonComplete,
                                let lastSeasonGameDate = viewModel.dateFormatter.date(from: viewModel.lastRound4GameDate),
                                viewModel.calendar.startOfDay(for: newCurrentDate) == viewModel.calendar.startOfDay(for: lastSeasonGameDate) {
                                    
                                userInfo.seasonComplete = true
                                viewModel.finishSimulation(simulationID: userInfo.simulationID) { _ in }
                                selectedDate = selectedDate.addingTimeInterval(1)
                            }
                        }
                        
                        // Fetch the playoff matchup of the selected date
                        viewModel.fetchTeamDayPlayoffSchedule(simulationID: userInfo.simulationID, teamID: viewModel.teams[selectedTeamIndex].teamID, date: stringDate) { scheduleFetched in
                            var opponentID: Int? = nil
                            if scheduleFetched, let playoffMatchupGame = viewModel.playoffMatchupGame {
                                opponentID = (viewModel.teams[selectedTeamIndex].teamID == playoffMatchupGame.awayTeamID ? playoffMatchupGame.homeTeamID : playoffMatchupGame.awayTeamID)
                            }
                            
                            // Fetch the playoff record of the team
                            viewModel.fetchTeamPlayoffStats(simulationID: userInfo.simulationID, teamID: viewModel.teams[selectedTeamIndex].teamID, opponentID: opponentID) { _ in }
                        }
                    }
                    
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
                .onChange(of: userInfo.isPlayoffs) { newValue in
                    currentDate = currentDate.addingTimeInterval(1)
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
                    EditRostersView(teamIndex: $selectedTeamIndex)
                        .environmentObject(userInfo)
                        .environmentObject(simulationState)
                        .navigationBarHidden(true)
                })
                .navigationDestination(isPresented: $showLineupsView, destination: {
                    // Navigate to Edit Lineups page when it's button is clicked
                    EditLineupsView(teamIndex: $selectedTeamIndex)
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
                
                ProgressView(LocalizedText.simulationSetupMessage.localizedString)
                    .appTextStyle()
                    .task {
                        selectedTeamIndex = userInfo.favTeamIndex
                        
                        if simulationState.isNewSim {
                            userInfo.resetPlayoffsInfo()
                            
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
    
    // View of the selected playoff team details and their playoff opponent details
    @ViewBuilder
    private func playoffMatchupView(playoffMatchupGame: PlayoffSchedule) -> some View {
        if isMatchupLoaded {
            HStack {
                teamBlockView(teamTitle: viewModel.teamTitle(date: selectedDate, teamID: playoffMatchupGame.awayTeamID, teamAbbrev: playoffMatchupGame.awayTeamAbbrev), teamLogo: playoffMatchupGame.awayTeamLogo, teamRecord: (viewModel.simPlayoffTeamStat?.teamID == playoffMatchupGame.awayTeamID) ? viewModel.teamPlayoffRecord(teamPlayoffStat: viewModel.simPlayoffTeamStat) : viewModel.teamPlayoffRecord(teamPlayoffStat: viewModel.simPlayoffOpponentStat))
                    .padding(.leading, Spacing.spacingExtraSmall)
                
                Text(Symbols.atSymbol.rawValue)
                    .appTextStyle()
                    .font(.caption)
                    .padding(.top, Spacing.spacingExtraSmall)
                
                teamBlockView(teamTitle: viewModel.teamTitle(date: selectedDate, teamID: playoffMatchupGame.homeTeamID, teamAbbrev: playoffMatchupGame.homeTeamAbbrev), teamLogo: playoffMatchupGame.homeTeamLogo, teamRecord: (viewModel.simPlayoffTeamStat?.teamID == playoffMatchupGame.homeTeamID) ? viewModel.teamPlayoffRecord(teamPlayoffStat: viewModel.simPlayoffTeamStat) : viewModel.teamPlayoffRecord(teamPlayoffStat: viewModel.simPlayoffOpponentStat))
                    .padding(.trailing, Spacing.spacingExtraSmall)
            }
        } else {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    // View of the Stanley Cup winner
    @ViewBuilder
    private func playoffWinnerView() -> some View {
        if isMatchupLoaded {
            HStack {
                teamBlockView(teamTitle: viewModel.winnerTeamName, teamLogo: viewModel.winnerTeamLogo, teamRecord: LocalizedText.winner.localizedString)
                    .padding(.leading, Spacing.spacingExtraSmall)
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
            
            let startOfCurrentDate = viewModel.calendar.startOfDay(for: currentDate)
            let startOfSelectedDate = viewModel.calendar.startOfDay(for: selectedDate)
            
            guard let daysToSimulate = viewModel.calendar.dateComponents([.day], from: startOfCurrentDate, to: startOfSelectedDate).day else {
                isInteractionDisabled = false
                return
            }
            
            if daysToSimulate <= 0 {
                isInteractionDisabled = false
                return
            }
            
            currentDate = currentDate.addingTimeInterval(1)
            
            simulateDay(simulatedDays: 0, daysToSimulate: daysToSimulate)
        } label: {
            if isInteractionDisabled {
                VStack {
                    if isGeneratingPlayoffs {
                        Text(LocalizedText.creatingPlayoffs.localizedString)
                            .appTextStyle()
                            .font(.body)
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                    } else {
                        Text(LocalizedText.simulating.localizedString)
                            .appTextStyle()
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                }
                .padding(Spacing.spacingExtraSmall)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                let selectedDateString = viewModel.dateFormatter.string(from: selectedDate)
                Text(String(format: LocalizedText.simulateTo.localizedString) + selectedDateString)
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
                if !isInteractionDisabled {
                    simulationState.isNewSim = false
                    showStandingsView = true
                }
            } label: {
                Text(LocalizedText.teamStandings.localizedString)
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
                if !isInteractionDisabled {
                    simulationState.isNewSim = false
                    showStatsView = true
                }
            } label: {
                Text(LocalizedText.playerStats.localizedString)
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
                if !isInteractionDisabled {
                    simulationState.isNewSim = false
                    showRostersView = true
                }
            } label: {
                Text(LocalizedText.editRosters.localizedString)
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
                if !isInteractionDisabled {
                    simulationState.isNewSim = false
                    showLineupsView = true
                }
            } label: {
                Text(LocalizedText.editLineups.localizedString)
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
        var daysToSim = 0
        
        if !userInfo.isPlayoffs, let lastGameDate = viewModel.dateFormatter.date(from: viewModel.lastGameDate), let lastGameFollowingDate = viewModel.calendar.date(byAdding: .day, value: 1, to: lastGameDate), viewModel.calendar.startOfDay(for: currentDate) == viewModel.calendar.startOfDay(for: lastGameFollowingDate) {
            daysToSim = 0
        } else if !userInfo.playoffRound1Complete, let lastRound1GameDate = viewModel.dateFormatter.date(from: viewModel.lastRound1GameDate), let lastRound1GameFollowingDate = viewModel.calendar.date(byAdding: .day, value: 1, to: lastRound1GameDate), viewModel.calendar.startOfDay(for: currentDate) == viewModel.calendar.startOfDay(for: lastRound1GameFollowingDate) {
            daysToSim = 0
        } else if !userInfo.playoffRound2Complete, let lastRound2GameDate = viewModel.dateFormatter.date(from: viewModel.lastRound2GameDate), let lastRound2GameFollowingDate = viewModel.calendar.date(byAdding: .day, value: 1, to: lastRound2GameDate), viewModel.calendar.startOfDay(for: currentDate) == viewModel.calendar.startOfDay(for: lastRound2GameFollowingDate) {
            daysToSim = 0
        } else if !userInfo.playoffRound3Complete, let lastRound3GameDate = viewModel.dateFormatter.date(from: viewModel.lastRound3GameDate), let lastRound3GameFollowingDate = viewModel.calendar.date(byAdding: .day, value: 1, to: lastRound3GameDate), viewModel.calendar.startOfDay(for: currentDate) == viewModel.calendar.startOfDay(for: lastRound3GameFollowingDate) {
            daysToSim = 0
        } else {
            daysToSim = daysToSimulate
        }
        
        if simulatedDays >= daysToSim {
            isInteractionDisabled = false
            currentDate = currentDate.addingTimeInterval(1)
            return
        }
            
        guard let nextDay = viewModel.calendar.date(byAdding: .day, value: 1, to: currentDate) else {
            isInteractionDisabled = false
            return
        }
            
        let stringSimulateDate = viewModel.dateFormatter.string(from: nextDay)
            
        viewModel.simulate(simulationID: userInfo.simulationID, simulateDate: stringSimulateDate, isPlayoffs: userInfo.isPlayoffs) { simulated in
            if simulated {
                currentDate = nextDay
                selectedDate = selectedDate.addingTimeInterval(1)
                simulateDay(simulatedDays: simulatedDays + 1, daysToSimulate: daysToSim)
            } else {
                isInteractionDisabled = false
            }
        }
    }
}
