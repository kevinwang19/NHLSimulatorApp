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
    @State private var isStatsLoaded: Bool = false
    @State private var selectedConference: ConferenceType = .all
    @State private var selectedEastDivision: EastDivisionType = .all
    @State private var selectedWestDivision: WestDivisionType = .all
    @State private var rankType: RankType = .league
    
    var body: some View {
        NavigationStack {
            VStack {
                if isStatsLoaded {
                    // Title and back button
                    ScreenHeaderView(returnToPreviousView: $returnToMainSimView)
                    
                    conferencePicker()
                        .padding(.top, Spacing.spacingSmall)
                    
                    // Show division pickers if a conference is picked
                    if selectedConference == .eastern {
                        eastDivisionPicker()
                            .padding(.top, Spacing.spacingSmall)
                    } else if selectedConference == .western {
                        westDivisionPicker()
                            .padding(.top, Spacing.spacingSmall)
                    }
                    
                    // Team stats grid view if there are stats
                    if viewModel.simTeamStats.count == 0 {
                        Text(LocalizedStringKey(LocalizedText.noStats.rawValue))
                            .appTextStyle()
                            .font(.footnote)
                            .padding(.top, Spacing.spacingExtraLarge)
                    } else {
                        TeamSortableStatsGridView(viewModel: viewModel, rankType: $rankType)
                    }
                    
                    // Stats legend
                    Text(LocalizedStringKey(LocalizedText.standingsLegend.rawValue))
                        .appTextStyle()
                        .font(.footnote)
                        .padding(.top, Spacing.spacingExtraLarge)
                    
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
                rankType = .league
                
                // Fetch all team stats initially
                viewModel.fetchAllTeamSimStats(simulationID: userInfo.simulationID) { statsFetched in
                    isStatsLoaded = statsFetched
                }
            }
            .onChange(of: selectedConference) { newConference in
                rankType = newConference == .all ? .league : .conference
                if newConference == .eastern {
                    selectedEastDivision = .all
                } else {
                    selectedWestDivision = .all
                }
                
                // Fetch team stats from the specific conference when the conference is selected
                viewModel.fetchConferenceTeamSimStats(simulationID: userInfo.simulationID, conference: newConference.rawValue)
            }
            .onChange(of: selectedEastDivision) { newDivision in
                rankType = newDivision == .all ? .conference : .division
                
                // Fetch team stats from the specific east division when the division is selected
                viewModel.fetchDivisionTeamSimStats(simulationID: userInfo.simulationID, conference: ConferenceType.eastern.rawValue, division: newDivision.rawValue)
            }
            .onChange(of: selectedWestDivision) { newDivision in
                rankType = newDivision == .all ? .conference : .division
                
                // Fetch team stats from the specific west division when the division is selected
                viewModel.fetchDivisionTeamSimStats(simulationID: userInfo.simulationID, conference: ConferenceType.western.rawValue, division: newDivision.rawValue)
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
}
