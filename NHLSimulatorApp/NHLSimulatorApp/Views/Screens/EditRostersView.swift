//
//  EditRostersView.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-08-05.
//

import SDWebImageSwiftUI
import SwiftUI

struct EditRostersView: View {
    @EnvironmentObject var userInfo: UserInfo
    @EnvironmentObject var simulationState: SimulationState
    @ObservedObject var viewModel: EditRostersViewModel = EditRostersViewModel()
    @Binding var teamIndex: Int
    @Binding var pastDeadline: Bool
    @State private var selectedTeamIndex: Int = -1
    @State private var otherTeamIndex: Int = -1
    @State private var showDropdown: Bool = false
    @State private var showOtherDropdown: Bool = false
    @State private var isDisabled: Bool = false
    @State private var isRosterLoaded: Bool = false
    @State private var isOtherRosterLoaded: Bool = false
    @State private var isSwitchTapped: Bool = false
    @State private var returnToMainSimView: Bool = false
    @State private var selectedPlayerIDs: [Int64] = []
    @State private var selectedOtherPlayerIDs: [Int64] = []
    @State private var grid1ScrollOffset: CGFloat = 0
    @State private var grid1IsAtTop: Bool = true
    @State private var grid1IsAtBottom: Bool = false
    @State private var grid2ScrollOffset: CGFloat = 0
    @State private var grid2IsAtTop: Bool = true
    @State private var grid2IsAtBottom: Bool = false
    private let maxPlayersDisplayed: Int = 5
    private var blockHeight: CGFloat = 45
    private var buttonWidth: CGFloat = 160
    
    init(teamIndex: Binding<Int>, pastDeadline: Binding<Bool>) {
        self._teamIndex = teamIndex
        self._pastDeadline = pastDeadline
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                // Title and back button
                ScreenHeaderView(returnToPreviousView: $returnToMainSimView, backButtonDisabled: $isDisabled)
                
                if pastDeadline {
                    Text(LocalizedText.pastDeadline.localizedString)
                        .appTextStyle()
                        .font(.callout)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, Spacing.spacingLarge)
                    
                    Spacer()
                } else {
                    // Instruction text
                    Text(LocalizedText.selectTeamChange.localizedString)
                        .appTextStyle()
                        .font(.footnote)
                        .frame(maxWidth: .infinity)
                        .padding(.top, Spacing.spacingExtraSmall)
                    
                    if isRosterLoaded {
                        VStack {
                            HStack {
                                // Drop down menu of all teams
                                TeamDropDownMenuView(selectedTeamIndex: $selectedTeamIndex, showDropdown: $showDropdown, teams: viewModel.teams, maxTeamsDisplayed: 5, isDisabled: $isDisabled)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                // Selected team logo
                                if viewModel.teams.indices.contains(selectedTeamIndex) {
                                    let url = URL(string: viewModel.teams[selectedTeamIndex].logo)
                                    
                                    WebImage(url: url)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 40)
                                        .padding(.trailing, Spacing.spacingSmall)
                                } else {
                                    Rectangle()
                                        .fill(.clear)
                                        .scaledToFit()
                                        .frame(height: 40)
                                        .padding(.trailing, Spacing.spacingSmall)
                                }
                            }
                            .zIndex(1)
                            
                            // List of selected team players
                            playersGridView()
                                .padding(.bottom, Spacing.spacingExtraSmall)
                                .zIndex(0)
                        }
                    } else {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    
                    if isOtherRosterLoaded {
                        VStack {
                            HStack {
                                // Drop down menu of all teams other than the selectedTeam
                                TeamDropDownMenuView(selectedTeamIndex: $otherTeamIndex, showDropdown: $showOtherDropdown, teams: viewModel.otherTeams, maxTeamsDisplayed: 5, isDisabled: $isDisabled)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                // Other team logo
                                if viewModel.otherTeams.indices.contains(otherTeamIndex) {
                                    let url = URL(string: viewModel.otherTeams[otherTeamIndex].logo)
                                    
                                    WebImage(url: url)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 40)
                                        .padding(.trailing, Spacing.spacingSmall)
                                } else {
                                    Rectangle()
                                        .fill(.clear)
                                        .scaledToFit()
                                        .frame(height: 40)
                                        .padding(.trailing, Spacing.spacingSmall)
                                }
                            }
                            .zIndex(1)
                            
                            // List of other team players
                            otherPlayersGridView()
                                .zIndex(0)
                        }
                    } else {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    
                    Spacer()
                    
                    // Success or error message
                    Text(viewModel.switchMessage)
                        .appTextStyle()
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                    
                    HStack {
                        // Clear selections button
                        Button {
                            viewModel.switchMessage = ""
                            selectedPlayerIDs = []
                            selectedOtherPlayerIDs = []
                        } label: {
                            Text(LocalizedText.clearSelections.localizedString)
                                .appTextStyle()
                                .font(.caption)
                                .padding(Spacing.spacingExtraSmall)
                                .frame(width: buttonWidth, alignment: .center)
                        }
                        .appButtonStyle()
                        
                        Spacer()
                        
                        // Switch players roster
                        Button {
                            viewModel.switchMessage = ""
                            
                            // Update other team index after removing the selected team index team
                            let updatedOtherTeamIndex = otherTeamIndex >= selectedTeamIndex ? otherTeamIndex + 1 : otherTeamIndex
                            
                            if viewModel.teams.indices.contains(selectedTeamIndex), viewModel.teams.indices.contains(updatedOtherTeamIndex) {
                                // Update lineups and rosters data
                                viewModel.updateRosters(teamID: viewModel.teams[selectedTeamIndex].teamID, playerIDs: selectedPlayerIDs, otherTeamID: viewModel.teams[updatedOtherTeamIndex].teamID, otherPlayerIDs: selectedOtherPlayerIDs) { _ in
                                    isSwitchTapped.toggle()
                                    selectedPlayerIDs = []
                                    selectedOtherPlayerIDs = []
                                }
                            }
                        } label: {
                            Text(LocalizedText.performSwitch.localizedString)
                                .appTextStyle()
                                .font(.caption)
                                .padding(Spacing.spacingExtraSmall)
                                .frame(width: buttonWidth, alignment: .center)
                        }
                        .appButtonStyle()
                    }
                    .padding(.bottom, Spacing.spacingExtraSmall)
                }
            }
            .padding(.horizontal, Spacing.spacingExtraSmall)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .appBackgroundStyle()
            .onAppear {
                // Set the initial teams
                selectedTeamIndex = teamIndex
                otherTeamIndex = 0
            }
            .onChange(of: selectedTeamIndex) { newIndex in
                isRosterLoaded = false
                
                if newIndex == otherTeamIndex {
                    otherTeamIndex = otherTeamIndex + 1
                }
                
                // Fetch the teams
                viewModel.fetchTeams(selectedTeamIndex: newIndex) { teamsFetched in
                    if teamsFetched, viewModel.teams.indices.contains(newIndex) {
                        
                        // Fetch the selected team players
                        viewModel.fetchTeamPlayers(teamID: viewModel.teams[newIndex].teamID, selectedTeamID: viewModel.teams[newIndex].teamID) { playersFetched in
                            isRosterLoaded = playersFetched
                        }
                    }
                }
            }
            .onChange(of: otherTeamIndex) { newIndex in
                isOtherRosterLoaded = false
                
                // Fetch the teams
                viewModel.fetchTeams(selectedTeamIndex: selectedTeamIndex) { teamsFetched in
                    if teamsFetched, viewModel.otherTeams.indices.contains(newIndex) {
                        // Update other team index after removing the selected team index team
                        let updatedNewIndex = newIndex >= selectedTeamIndex ? newIndex + 1 : newIndex
                        
                        // Fetch the other team players
                        viewModel.fetchTeamPlayers(teamID: viewModel.teams[updatedNewIndex].teamID, selectedTeamID: viewModel.teams[selectedTeamIndex].teamID) { playersFetched in
                            isOtherRosterLoaded = playersFetched
                        }
                    }
                }
            }
            .onChange(of: isSwitchTapped, perform: { _ in
                isRosterLoaded = false
                isOtherRosterLoaded = false
                
                // Fetch the teams
                viewModel.fetchTeams(selectedTeamIndex: selectedTeamIndex) { teamsFetched in
                    if teamsFetched, viewModel.teams.indices.contains(selectedTeamIndex), viewModel.teams.indices.contains(otherTeamIndex) {
                        // Update other team index after removing the selected team index team
                        let updatedOtherTeamIndex = otherTeamIndex >= selectedTeamIndex ? otherTeamIndex + 1 : otherTeamIndex
                        
                        // Fetch the selected and other team players
                        viewModel.fetchTeamPlayers(teamID: viewModel.teams[selectedTeamIndex].teamID, selectedTeamID: viewModel.teams[selectedTeamIndex].teamID) { playersFetched in
                            isRosterLoaded = playersFetched
                        }
                        
                        viewModel.fetchTeamPlayers(teamID: viewModel.teams[updatedOtherTeamIndex].teamID, selectedTeamID: viewModel.teams[selectedTeamIndex].teamID) { playersFetched in
                            isOtherRosterLoaded = playersFetched
                        }
                    }
                }
            })
            .onChange(of: showDropdown) { newShowDropdown in
                showOtherDropdown = newShowDropdown ? false : showOtherDropdown
            }
            .onChange(of: showOtherDropdown) { newShowOtherDropdown in
                showDropdown = newShowOtherDropdown ? false : showDropdown
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
    
    // View of the selected team roster lists
    @ViewBuilder
    private func playersGridView() -> some View {
        VStack {
            ZStack {
                let scrollViewHeight: CGFloat = viewModel.players.count > maxPlayersDisplayed ? (blockHeight * CGFloat(maxPlayersDisplayed)) : (blockHeight * CGFloat(viewModel.players.count))
                
                ScrollView(.vertical) {
                    LazyVStack(spacing: 1) {
                        // Rows of players
                        ForEach(viewModel.players, id: \.self) { player in
                            playerRowView(player: player)
                        }
                    }
                    .background(GeometryReader { geometry in
                        Color.clear
                            .preference(key: ScrollOffsetPreferenceKey.self, value: geometry.frame(in: .named(ElementLabel.scroll.rawValue)).minY)
                    })
                    .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                        // Detect position of the scrolling for displaying the gradients
                        grid1ScrollOffset = value
                        grid1IsAtTop = (grid1ScrollOffset >= 0)
                        grid1IsAtBottom = (grid1ScrollOffset <= ((CGFloat(viewModel.players.count - maxPlayersDisplayed) * blockHeight) * -1))
                    }
                    .overlay(
                        Color.white.opacity(showDropdown ? 0.15 : 0.0)
                            .cornerRadius(10)
                    )
                }
                .coordinateSpace(name: ElementLabel.scroll.rawValue)
                .scrollDisabled(viewModel.players.count <= maxPlayersDisplayed)
                .frame(height: scrollViewHeight)
                .appButtonStyle()
                
                // Gradient for more scrollable players
                if viewModel.players.count > maxPlayersDisplayed && !showDropdown {
                    VStack {
                        if !grid1IsAtTop {
                            LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.7), Color.clear]), startPoint: .top, endPoint: .bottom)
                                .frame(height: blockHeight)
                                .cornerRadius(10)
                        }
                        Spacer()
                        if !grid1IsAtBottom {
                            LinearGradient(gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.7)]), startPoint: .top, endPoint: .bottom)
                                .frame(height: blockHeight)
                                .cornerRadius(10)
                        }
                    }
                }
            }
            .frame(maxHeight: blockHeight * CGFloat(maxPlayersDisplayed))
        }
    }
    
    // View of the selected other team roster lists
    @ViewBuilder
    private func otherPlayersGridView() -> some View {
        VStack {
            ZStack {
                let scrollViewHeight: CGFloat = viewModel.otherPlayers.count > maxPlayersDisplayed ? (blockHeight * CGFloat(maxPlayersDisplayed)) : (blockHeight * CGFloat(viewModel.otherPlayers.count))
                
                ScrollView(.vertical) {
                    LazyVStack(spacing: 1) {
                        // Rows of players
                        ForEach(viewModel.otherPlayers, id: \.self) { player in
                            otherPlayerRowView(player: player)
                        }
                    }
                    .background(GeometryReader { geometry in
                        Color.clear
                            .preference(key: ScrollOffsetPreferenceKey.self, value: geometry.frame(in: .named(ElementLabel.scroll.rawValue)).minY)
                    })
                    .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                        // Detect position of the scrolling for displaying the gradients
                        grid2ScrollOffset = value
                        grid2IsAtTop = (grid2ScrollOffset >= 0)
                        grid2IsAtBottom = (grid2ScrollOffset <= ((CGFloat(viewModel.otherPlayers.count - maxPlayersDisplayed) * blockHeight) * -1))
                    }
                    .overlay(
                        Color.white.opacity(showOtherDropdown ? 0.15 : 0.0)
                            .cornerRadius(10)
                    )
                }
                .coordinateSpace(name: ElementLabel.scroll.rawValue)
                .scrollDisabled(viewModel.otherPlayers.count <= maxPlayersDisplayed)
                .frame(height: scrollViewHeight)
                .appButtonStyle()
                
                // Gradient for more scrollable players
                if viewModel.otherPlayers.count > maxPlayersDisplayed && !showOtherDropdown {
                    VStack {
                        if !grid2IsAtTop {
                            LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.7), Color.clear]), startPoint: .top, endPoint: .bottom)
                                .frame(height: blockHeight)
                                .cornerRadius(10)
                        }
                        Spacer()
                        if !grid2IsAtBottom {
                            LinearGradient(gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.7)]), startPoint: .top, endPoint: .bottom)
                                .frame(height: blockHeight)
                                .cornerRadius(10)
                        }
                    }
                }
            }
            .frame(maxHeight: blockHeight * CGFloat(maxPlayersDisplayed))
        }
    }
    
    // View of the each player block in the list
    @ViewBuilder
    private func playerRowView(player: CorePlayer) -> some View {
        let fullName = (player.firstName ?? "") + " " + (player.lastName ?? "")
        
        Button {
            selectedPlayerIDs.append(player.playerID)
        } label: {
            Text(fullName.uppercased())
                .foregroundColor(selectedPlayerIDs.contains(player.playerID) ? Color.black : Color.white)
                .appTextStyle()
                .font(.footnote)
                .padding(.all, Spacing.spacingSmall)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: blockHeight)
        .background((selectedPlayerIDs.contains(player.playerID) || selectedOtherPlayerIDs.contains(player.playerID)) ? Color.white.cornerRadius(10) : Color.black.cornerRadius(10))
    }
    
    // View of the each other player block in the list
    @ViewBuilder
    private func otherPlayerRowView(player: CorePlayer) -> some View {
        let fullName = (player.firstName ?? "") + " " + (player.lastName ?? "")
        
        Button {
            selectedOtherPlayerIDs.append(player.playerID)
        } label: {
            Text(fullName.uppercased())
                .foregroundColor(selectedOtherPlayerIDs.contains(player.playerID) ? Color.black : Color.white)
                .appTextStyle()
                .font(.footnote)
                .padding(.all, Spacing.spacingSmall)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: blockHeight)
        .background((selectedPlayerIDs.contains(player.playerID) || selectedOtherPlayerIDs.contains(player.playerID)) ? Color.white.cornerRadius(10) : Color.black.cornerRadius(10))
    }
}
