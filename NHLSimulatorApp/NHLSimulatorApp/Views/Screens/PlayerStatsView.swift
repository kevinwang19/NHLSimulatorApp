//
//  PlayerStatsView.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-08-05.
//

import SDWebImageSwiftUI
import SwiftUI

enum PlayerType: String, CaseIterable, Identifiable {
    case skaters
    case goalies
    
    var id: String { self.rawValue }
    
    var localizedStringKey: LocalizedStringKey {
        LocalizedStringKey(self.rawValue)
    }
}

enum PositionType: String, CaseIterable, Identifiable {
    case all
    case forwards
    case centers
    case leftWingers = "left_wingers"
    case rightWingers = "right_wingers"
    case defensemen
    
    var id: String { self.rawValue }
    
    var localizedStringKey: LocalizedStringKey {
        LocalizedStringKey(self.rawValue)
    }
}

struct PlayerStatsView: View {
    @EnvironmentObject var userInfo: UserInfo
    @EnvironmentObject var simulationState: SimulationState
    @ObservedObject var viewModel: PlayerStatsViewModel = PlayerStatsViewModel()
    @State private var selectedTeamIndex: Int = 0
    @State private var showDropdown: Bool = false
    @State private var isDisabled: Bool = false
    @State private var returnToMainSimView: Bool = false
    @State private var isStatsLoaded: Bool = false
    @State private var selectedPlayerType: PlayerType = .skaters
    @State private var selectedPositionType: PositionType = .all
    @State private var skaterSimStats: [SimulationSkaterStat] = []
    @State private var goalieSimStats: [SimulationGoalieStat] = []
    
    var body: some View {
        NavigationStack {
            VStack {
                if isStatsLoaded {
                    // Title
                    ZStack {
                        Button {
                            returnToMainSimView = true
                        } label: {
                            HStack {
                                Image(systemName: Symbols.leftArrow.rawValue)
                                    .labelStyle(IconOnlyLabelStyle())
                                
                                Text(LocalizedStringKey(LocalizedText.back.rawValue))
                            }
                            .font(.footnote)
                            .appTextStyle()
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text(LocalizedStringKey(LocalizedText.nhlSimulator.rawValue))
                            .appTextStyle()
                            .font(.headline)
                            .padding(.top, Spacing.spacingExtraSmall)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    
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
                    
                    if selectedPlayerType == .skaters {
                        positionTypePicker()
                            .padding(.top, Spacing.spacingSmall)
                    }
                    
                    StatsGridView(viewModel: viewModel, selectedPlayerType: $selectedPlayerType)
                    
                    Spacer()
                } else {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .appBackgroundStyle()
                }
            }
            .padding(.horizontal, Spacing.spacingExtraSmall)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .appBackgroundStyle()
            .onAppear {
                selectedTeamIndex = userInfo.favTeamIndex
            }
            .onChange(of: selectedTeamIndex) { newIndex in
                selectedPositionType = .all
                
                viewModel.fetchPlayerSimStats(simulationID: userInfo.simulationID, teamID: viewModel.teams[newIndex].teamID) { statsFetched in
                    isStatsLoaded = statsFetched
                }
            }
            .onChange(of: selectedPositionType) { newPosition in
                viewModel.fetchSkaterPositionSimStats(simulationID: userInfo.simulationID, teamID: viewModel.teams[selectedTeamIndex].teamID, position: newPosition.rawValue)
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
    
    @ViewBuilder
    private func positionTypePicker() -> some View {
        HStack {
            ForEach(PositionType.allCases) { type in
                Button(action: {
                    selectedPositionType = type
                }) {
                    Text(type.localizedStringKey)
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
