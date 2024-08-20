//
//  TeamStandingsView.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-08-05.
//

import SwiftUI

struct TeamStandingsView: View {
    @EnvironmentObject var userInfo: UserInfo
    @EnvironmentObject var simulationState: SimulationState
    @ObservedObject var viewModel: TeamStandingsViewModel = TeamStandingsViewModel()
    @State private var returnToMainSimView: Bool = false
    @State private var backButtonDisabled: Bool = false
    @State private var isStatsLoaded: Bool = false
    @State private var selectedGameType: GameType = .regular
    @State private var selectedConference: ConferenceType = .all
    @State private var selectedEastDivision: EastDivisionType = .all
    @State private var selectedWestDivision: WestDivisionType = .all
    @State private var selectedPlayoffDisplay: PlayoffDisplayType = .teamStats
    @State private var rankType: RankType = .league
    
    var body: some View {
        NavigationStack {
            VStack {
               // Title and back button
                ScreenHeaderView(returnToPreviousView: $returnToMainSimView, backButtonDisabled: $backButtonDisabled)
                    
                // Regular season or playoffs picker
                if userInfo.isPlayoffs {
                    gameTypePicker()
                        .padding(.top, Spacing.spacingSmall)
                }
                
                // Team conference picker
                conferencePicker()
                    .padding(.top, Spacing.spacingSmall)
                    
                // Show division pickers if a conference is picked and if it is not the playoffs
                if selectedGameType == .regular && selectedConference == .eastern {
                    eastDivisionPicker()
                        .padding(.top, Spacing.spacingSmall)
                } else if selectedGameType == .regular && selectedConference == .western {
                    westDivisionPicker()
                        .padding(.top, Spacing.spacingSmall)
                } else if (selectedGameType == .playoffs && selectedConference == .eastern) ||
                            (selectedGameType == .playoffs && selectedConference == .western) {
                    playoffDisplayPicker()
                        .padding(.top, Spacing.spacingSmall)
                }
                    
                // Team stats grid view if there are stats
                if (selectedGameType == .regular && viewModel.simTeamStats.count == 0) ||
                    (selectedGameType == .playoffs && viewModel.simTeamPlayoffStats.count == 0) {
                    Text(LocalizedText.noStats.localizedString)
                        .appTextStyle()
                        .font(.footnote)
                        .padding(.top, Spacing.spacingExtraLarge)
                } else {
                    if isStatsLoaded && selectedPlayoffDisplay == .teamStats {
                        TeamSortableStatsGridView(viewModel: viewModel, selectedGameType: $selectedGameType, rankType: $rankType)
                    } else if isStatsLoaded && selectedPlayoffDisplay == .playoffTree && selectedConference != .all {
                        PlayoffTreeView(playoffTreeStats: $viewModel.simTeamPlayoffStats, selectedConference: $selectedConference)
                    } else {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                    
                if selectedPlayoffDisplay == .teamStats {
                    // Stats legend
                    Text(LocalizedText.standingsLegend.localizedString)
                        .appTextStyle()
                        .font(.footnote)
                        .padding(.top, Spacing.spacingExtraLarge)
                }
                
                Spacer()
            }
            .padding(.horizontal, Spacing.spacingExtraSmall)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .appBackgroundStyle()
            .onAppear {
                rankType = .league
                
                if userInfo.isPlayoffs {
                    selectedGameType = .playoffs
                }
                
                // Fetch all team stats initially
                if selectedGameType == .playoffs {
                    viewModel.fetchAllTeamSimPlayoffStats(simulationID: userInfo.simulationID) { statsFetched in
                        isStatsLoaded = statsFetched
                    }
                } else {
                    viewModel.fetchAllTeamSimStats(simulationID: userInfo.simulationID) { statsFetched in
                        isStatsLoaded = statsFetched
                    }
                }
            }
            .onChange(of: selectedConference) { newConference in
                isStatsLoaded = false
                rankType = newConference == .all ? .league : .conference
                
                if newConference == .eastern && selectedPlayoffDisplay != .playoffTree {
                    selectedEastDivision = .all
                } else if newConference == .western && selectedPlayoffDisplay != .playoffTree {
                    selectedWestDivision = .all
                } else if newConference == .all {
                    selectedPlayoffDisplay = .teamStats
                }
                
                if selectedPlayoffDisplay == .teamStats {
                    // Fetch team stats from the specific conference when the conference is selected
                    if selectedGameType == .playoffs {
                        viewModel.fetchConferenceTeamSimPlayoffStats(simulationID: userInfo.simulationID, conference: newConference.rawValue) { statsFetched in
                            isStatsLoaded = statsFetched
                        }
                    } else {
                        viewModel.fetchConferenceTeamSimStats(simulationID: userInfo.simulationID, conference: newConference.rawValue) { statsFetched in
                            isStatsLoaded = statsFetched
                        }
                    }
                } else {
                    viewModel.fetchPlayoffTreeStats(simulationID: userInfo.simulationID, conference: selectedConference.rawValue) { statsFetched in
                        isStatsLoaded = statsFetched
                    }
                }
            }
            .onChange(of: selectedEastDivision) { newDivision in
                isStatsLoaded = false
                rankType = newDivision == .all ? .conference : .division
                
                // Fetch team stats from the specific east division when the division is selected
                viewModel.fetchDivisionTeamSimStats(simulationID: userInfo.simulationID, conference: ConferenceType.eastern.rawValue, division: newDivision.rawValue) { statsFetched in
                    isStatsLoaded = statsFetched
                }
            }
            .onChange(of: selectedWestDivision) { newDivision in
                isStatsLoaded = false
                rankType = newDivision == .all ? .conference : .division
                
                // Fetch team stats from the specific west division when the division is selected
                viewModel.fetchDivisionTeamSimStats(simulationID: userInfo.simulationID, conference: ConferenceType.western.rawValue, division: newDivision.rawValue) { statsFetched in
                    isStatsLoaded = statsFetched
                }
            }
            .onChange(of: selectedGameType) { newGameType in
                isStatsLoaded = false
                selectedConference = .all
                viewModel.simTeamStats = []
                viewModel.simTeamPlayoffStats = []
                
                // Fetch the team regular season or playoffs stats
                if newGameType == .playoffs {
                    viewModel.fetchAllTeamSimPlayoffStats(simulationID: userInfo.simulationID) { statsFetched in
                        isStatsLoaded = statsFetched
                    }
                } else {
                    viewModel.fetchAllTeamSimStats(simulationID: userInfo.simulationID) { statsFetched in
                        isStatsLoaded = statsFetched
                    }
                }
            }
            .onChange(of: selectedPlayoffDisplay) { newDisplay in
                isStatsLoaded = false
                viewModel.simTeamPlayoffStats = []
                
                // Fetch the team stats or playoff tree
                if newDisplay == .playoffTree {
                    viewModel.fetchPlayoffTreeStats(simulationID: userInfo.simulationID, conference: selectedConference.rawValue) { statsFetched in
                        isStatsLoaded = statsFetched
                    }
                } else {
                    viewModel.fetchConferenceTeamSimPlayoffStats(simulationID: userInfo.simulationID, conference: selectedConference.rawValue) { statsFetched in
                        isStatsLoaded = statsFetched
                    }
                }
            }
            .navigationDestination(isPresented: $returnToMainSimView, destination: {
                // Navigate to Main Sim page when back button is clicked
                MainSimView()
                    .environmentObject(userInfo)
                    .environmentObject(simulationState)
                    .navigationBarHidden(true)
            })
        }
    }
    
    // View of the picker of regular season or playoffs stats
    @ViewBuilder
    private func gameTypePicker() -> some View {
        HStack {
            ForEach(GameType.allCases) { type in
                Button(action: {
                    selectedGameType = type
                }) {
                    Text(type.localizedStringKey)
                        .frame(maxWidth: .infinity)
                        .padding(Spacing.spacingExtraSmall)
                        .font(.footnote)
                        .background(selectedGameType == type ? Color.white : Color.black)
                        .foregroundColor(selectedGameType == type ? Color.black : Color.white)
                        .appTextStyle()
                        .appButtonStyle()
                }
            }
        }
    }
    
    // View of the picker of the different team conferences
    @ViewBuilder
    private func conferencePicker() -> some View {
        HStack {
            ForEach(ConferenceType.allCases) { type in
                Button(action: {
                    selectedConference = type
                }) {
                    Text(type.localizedStringKey)
                        .frame(maxWidth: .infinity)
                        .padding(Spacing.spacingExtraSmall)
                        .font(.footnote)
                        .background(selectedConference == type ? Color.white : Color.black)
                        .foregroundColor(selectedConference == type ? Color.black : Color.white)
                        .appTextStyle()
                        .appButtonStyle()
                }
            }
        }
    }
    
    // View of the picker of the different east team divisions
    @ViewBuilder
    private func eastDivisionPicker() -> some View {
        HStack {
            ForEach(EastDivisionType.allCases) { type in
                Button(action: {
                    selectedEastDivision = type
                }) {
                    Text(type.localizedStringKey)
                        .frame(maxWidth: .infinity)
                        .padding(Spacing.spacingExtraSmall)
                        .font(.caption)
                        .background(selectedEastDivision == type ? Color.white : Color.black)
                        .foregroundColor(selectedEastDivision == type ? Color.black : Color.white)
                        .appTextStyle()
                        .appButtonStyle()
                }
            }
        }
    }
    
    // View of the picker of the different west team divisions
    @ViewBuilder
    private func westDivisionPicker() -> some View {
        HStack {
            ForEach(WestDivisionType.allCases) { type in
                Button(action: {
                    selectedWestDivision = type
                }) {
                    Text(type.localizedStringKey)
                        .frame(maxWidth: .infinity)
                        .padding(Spacing.spacingExtraSmall)
                        .font(.footnote)
                        .background(selectedWestDivision == type ? Color.white : Color.black)
                        .foregroundColor(selectedWestDivision == type ? Color.black : Color.white)
                        .appTextStyle()
                        .appButtonStyle()
                }
            }
        }
    }
    
    // View of the picker of the playoff stats display
    @ViewBuilder
    private func playoffDisplayPicker() -> some View {
        HStack {
            ForEach(PlayoffDisplayType.allCases) { type in
                Button(action: {
                    selectedPlayoffDisplay = type
                }) {
                    Text(type.localizedStringKey)
                        .frame(maxWidth: .infinity)
                        .padding(Spacing.spacingExtraSmall)
                        .font(.footnote)
                        .background(selectedPlayoffDisplay == type ? Color.white : Color.black)
                        .foregroundColor(selectedPlayoffDisplay == type ? Color.black : Color.white)
                        .appTextStyle()
                        .appButtonStyle()
                }
            }
        }
    }
}
