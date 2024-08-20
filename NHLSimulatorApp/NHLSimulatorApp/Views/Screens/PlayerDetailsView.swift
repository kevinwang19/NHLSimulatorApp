//
//  PlayerDetailsView.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-08-07.
//

import SDWebImageSwiftUI
import SwiftUI

struct PlayerDetailsView: View {
    @EnvironmentObject var userInfo: UserInfo
    @EnvironmentObject var simulationState: SimulationState
    @ObservedObject var viewModel: PlayerDetailsViewModel = PlayerDetailsViewModel()
    @Binding var selectedPlayerID: Int
    @Binding var teamIndex: Int
    @State private var returnToPlayerStatsView: Bool = false
    @State private var backButtonDisabled: Bool = false
    @State private var isDetailsLoaded: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                // Title and back button
                ScreenHeaderView(returnToPreviousView: $returnToPlayerStatsView, backButtonDisabled: $backButtonDisabled)
                        
                if isDetailsLoaded, let player = viewModel.playerDetails(playerID: selectedPlayerID) {
                    HStack {
                        // Player info
                        playerInfoView(player: player)
                            
                        // Player headshot
                        WebImage(url: URL(string: player.headshot ?? ""))
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                            .padding(.trailing, Spacing.spacingSmall)
                    }
                    .padding(.top, Spacing.spacingExtraSmall)
                        
                    Text(LocalizedText.careerStats.localizedString)
                        .appTextStyle()
                        .font(.callout)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, Spacing.spacingSmall)
                        .padding(.leading, Spacing.spacingExtraSmall)
                        
                    // Career stats
                    PlayerStatsGridView(skaterStats: $viewModel.skaterCareerStats, goalieStats: $viewModel.goalieCareerStats, position: player.positionCode ?? "")
                    
                    Text(LocalizedText.predictedStats.localizedString)
                        .appTextStyle()
                        .font(.callout)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, Spacing.spacingMedium)
                        .padding(.leading, Spacing.spacingExtraSmall)
                        
                    // Predicted stats
                    PlayerStatsGridView(skaterStats: $viewModel.skaterPredictedStats, goalieStats: $viewModel.goaliePredictedStats, position: player.positionCode ?? "")
                } else {
                    Text(LocalizedText.noPlayerDetails.localizedString)
                        .appTextStyle()
                        .font(.footnote)
                        .padding(.horizontal, Spacing.spacingExtraSmall)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .padding(.horizontal, Spacing.spacingExtraSmall)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .appBackgroundStyle()
            .onAppear {
                isDetailsLoaded = false
                if let teamID = viewModel.playerDetails(playerID: selectedPlayerID)?.teamID, let position = viewModel.playerDetails(playerID: selectedPlayerID)?.positionCode {
                    // Fetch the player's team name
                    viewModel.fetchPlayerTeam(teamID: Int(teamID)) { teamFetched in
                        if teamFetched {
                            viewModel.fetchPlayerStats(playerID: selectedPlayerID, position: position) { statsFetched in
                                isDetailsLoaded = statsFetched
                            }
                        }
                    }
                }
            }
            .navigationDestination(isPresented: $returnToPlayerStatsView, destination: {
                // Navigate to Player Stats page when back button is clicked
                PlayerStatsView(teamIndex: $teamIndex)
                    .environmentObject(userInfo)
                    .environmentObject(simulationState)
                    .navigationBarHidden(true)
            })
        }
    }
    
    @ViewBuilder
    private func playerInfoView(player: CorePlayer) -> some View {
        VStack {
            // Player's name
            let fullName = ((player.firstName ?? "") + " " + (player.lastName ?? "")).uppercased()
            Text(fullName)
                .appTextStyle()
                .font(.title2)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 1)
               
            // Player's team, position, and sweater number
            let teamInfo = viewModel.team?.fullName ?? "" + Symbols.dot.rawValue + NSLocalizedString(player.positionCode ?? "", comment: "") + Symbols.dot.rawValue + Symbols.number.rawValue + "\(player.sweaterNumber)"
            Text(teamInfo)
                .appTextStyle()
                .font(.footnote)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 1)
            
            // Player's birth date and country
            let birthInfo = LocalizedText.born.localizedString + " " + (player.birthDate ?? "") + Symbols.dot.rawValue + (player.birthCountry ?? "")
            Text(birthInfo)
                .appTextStyle()
                .font(.footnote)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 1)
                   
            // Player's height and weight
            let heightFeet = player.heightInInches / 12
            let heightInches = player.heightInInches % 12
            let heightInfo = LocalizedText.height.localizedString + " " + "\(heightFeet)" + Symbols.feet.rawValue + "\(heightInches)" + Symbols.inch.rawValue +  Symbols.dot.rawValue + LocalizedText.weight.localizedString + " " + "\(player.weightInPounds)" + " " + Symbols.pounds.rawValue
            Text(heightInfo)
                .appTextStyle()
                .font(.footnote)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.all, Spacing.spacingExtraSmall)
    }
}
