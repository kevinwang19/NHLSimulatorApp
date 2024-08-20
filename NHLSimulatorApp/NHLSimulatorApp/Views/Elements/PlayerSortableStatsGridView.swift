//
//  PlayerSortableStatsGridView.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-08-05.
//

import SwiftUI

struct PlayerSortableStatsGridView: View {
    @ObservedObject var viewModel: PlayerStatsViewModel
    @Binding var selectedGameType: GameType
    @Binding var selectedPlayerType: PlayerType
    @Binding var showPlayerDetailsView: Bool
    @Binding var selectedPlayerID: Int
    @State var sortOrder: SortOrder = .pointsDescending
    private let nameColumnWidth: CGFloat = 180
    private let statColumnWidth: CGFloat = 50
    private let maxRows: Int = 50
    
    var body: some View {
        VStack {
            ScrollView(.vertical) {
                LazyVStack {
                    ScrollView(.horizontal) {
                        VStack {
                            if selectedPlayerType == .skaters {
                                skaterStatsHeader()
                                skaterStatsRows()
                            } else if selectedPlayerType == .goalies {
                                goalieStatsHeader()
                                goalieStatsRows()
                            }
                        }
                    }
                }
                .padding(Spacing.spacingExtraSmall)
            }
        }
        .onChange(of: selectedPlayerType) { newType in
            sortOrder = newType == .skaters ? .pointsDescending : .winsDescending
        }
    }
    
    // Skater stats header view
    @ViewBuilder
    private func skaterStatsHeader() -> some View {
        HStack {
            GridHeaderView(title: StatColumnHeader.name.localizedString, sortOrder: $sortOrder, skaterKeyPath: \SimulationSkaterStat.fullName, goalieKeyPath: nil, teamKeyPath: nil)
            GridHeaderView(title: StatColumnHeader.gamesPlayed.localizedString, sortOrder: $sortOrder, skaterKeyPath: \SimulationSkaterStat.gamesPlayed, goalieKeyPath: nil, teamKeyPath: nil)
            GridHeaderView(title: StatColumnHeader.goals.localizedString, sortOrder: $sortOrder, skaterKeyPath: \SimulationSkaterStat.goals, goalieKeyPath: nil, teamKeyPath: nil)
            GridHeaderView(title: StatColumnHeader.assists.localizedString, sortOrder: $sortOrder, skaterKeyPath: \SimulationSkaterStat.assists, goalieKeyPath: nil, teamKeyPath: nil)
            GridHeaderView(title: StatColumnHeader.points.localizedString, sortOrder: $sortOrder, skaterKeyPath: \SimulationSkaterStat.points, goalieKeyPath: nil, teamKeyPath: nil)
            GridHeaderView(title: StatColumnHeader.powerPlayGoals.localizedString, sortOrder: $sortOrder, skaterKeyPath: \SimulationSkaterStat.powerPlayGoals, goalieKeyPath: nil, teamKeyPath: nil)
            GridHeaderView(title: StatColumnHeader.powerPlayPoints.localizedString, sortOrder: $sortOrder, skaterKeyPath: \SimulationSkaterStat.powerPlayPoints, goalieKeyPath: nil, teamKeyPath: nil)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // Skater stats rows view
    @ViewBuilder
    private func skaterStatsRows() -> some View {
        if selectedGameType == .regular {
            ForEach(skaterSortedItems(), id: \.self) { item in
                Button {
                    showPlayerDetailsView = true
                    selectedPlayerID = item.playerID
                } label: {
                    HStack {
                        Text(item.fullName)
                            .frame(width: nameColumnWidth, alignment: .leading)
                        Text("\(item.gamesPlayed)")
                            .frame(width: statColumnWidth, alignment: .center)
                        Text("\(item.goals)")
                            .frame(width: statColumnWidth, alignment: .center)
                        Text("\(item.assists)")
                            .frame(width: statColumnWidth, alignment: .center)
                        Text("\(item.points)")
                            .frame(width: statColumnWidth, alignment: .center)
                        Text("\(item.powerPlayGoals)")
                            .frame(width: statColumnWidth, alignment: .center)
                        Text("\(item.powerPlayPoints)")
                            .frame(width: statColumnWidth, alignment: .center)
                    }
                }
                .appTextStyle()
                .font(.footnote)
                .padding(.vertical, 5)
                .frame(maxWidth: .infinity, alignment: .leading)
                .cornerRadius(10)
            }
        } else {
            ForEach(skaterPlayoffsSortedItems(), id: \.self) { item in
                Button {
                    showPlayerDetailsView = true
                    selectedPlayerID = item.playerID
                } label: {
                    HStack {
                        Text(item.fullName)
                            .frame(width: nameColumnWidth, alignment: .leading)
                        Text("\(item.gamesPlayed)")
                            .frame(width: statColumnWidth, alignment: .center)
                        Text("\(item.goals)")
                            .frame(width: statColumnWidth, alignment: .center)
                        Text("\(item.assists)")
                            .frame(width: statColumnWidth, alignment: .center)
                        Text("\(item.points)")
                            .frame(width: statColumnWidth, alignment: .center)
                        Text("\(item.powerPlayGoals)")
                            .frame(width: statColumnWidth, alignment: .center)
                        Text("\(item.powerPlayPoints)")
                            .frame(width: statColumnWidth, alignment: .center)
                    }
                }
                .appTextStyle()
                .font(.footnote)
                .padding(.vertical, 5)
                .frame(maxWidth: .infinity, alignment: .leading)
                .cornerRadius(10)
            }
        }
    }

    // Goalie stats header view
    @ViewBuilder
    private func goalieStatsHeader() -> some View {
        HStack {
            GridHeaderView(title: StatColumnHeader.name.localizedString, sortOrder: $sortOrder, skaterKeyPath: nil, goalieKeyPath: \SimulationGoalieStat.fullName, teamKeyPath: nil)
            GridHeaderView(title: StatColumnHeader.gamesPlayed.localizedString, sortOrder: $sortOrder, skaterKeyPath: nil, goalieKeyPath: \SimulationGoalieStat.gamesPlayed, teamKeyPath: nil)
            GridHeaderView(title: StatColumnHeader.wins.localizedString, sortOrder: $sortOrder, skaterKeyPath: nil, goalieKeyPath: \SimulationGoalieStat.wins, teamKeyPath: nil)
            GridHeaderView(title: StatColumnHeader.losses.localizedString, sortOrder: $sortOrder, skaterKeyPath: nil, goalieKeyPath: \SimulationGoalieStat.losses, teamKeyPath: nil)
            GridHeaderView(title: StatColumnHeader.otLosses.localizedString, sortOrder: $sortOrder, skaterKeyPath: nil, goalieKeyPath: \SimulationGoalieStat.otLosses, teamKeyPath: nil)
            GridHeaderView(title: StatColumnHeader.goalsAgainstPerGame.localizedString, sortOrder: $sortOrder, skaterKeyPath: nil, goalieKeyPath: \SimulationGoalieStat.goalsAgainstPerGame, teamKeyPath: nil)
            GridHeaderView(title: StatColumnHeader.shutouts.localizedString, sortOrder: $sortOrder, skaterKeyPath: nil, goalieKeyPath: \SimulationGoalieStat.shutouts, teamKeyPath: nil)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // Goalie stats rows view
    @ViewBuilder
    private func goalieStatsRows() -> some View {
        if selectedGameType == .regular {
            ForEach(goalieSortedItems(), id: \.self) { item in
                Button {
                    showPlayerDetailsView = true
                    selectedPlayerID = item.playerID
                } label: {
                    HStack {
                        Text(item.fullName)
                            .frame(width: nameColumnWidth, alignment: .leading)
                        Text("\(item.gamesPlayed)")
                            .frame(width: statColumnWidth, alignment: .center)
                        Text("\(item.wins)")
                            .frame(width: statColumnWidth, alignment: .center)
                        Text("\(item.losses)")
                            .frame(width: statColumnWidth, alignment: .center)
                        Text("\(item.otLosses)")
                            .frame(width: statColumnWidth, alignment: .center)
                        Text(String(format: "%.2f", item.goalsAgainstPerGame))
                            .frame(width: statColumnWidth, alignment: .center)
                        Text("\(item.shutouts)")
                            .frame(width: statColumnWidth, alignment: .center)
                    }
                }
                .appTextStyle()
                .font(.footnote)
                .padding(.vertical, 5)
                .frame(maxWidth: .infinity, alignment: .leading)
                .cornerRadius(10)
            }
        } else {
            ForEach(goaliePlayoffsSortedItems(), id: \.self) { item in
                Button {
                    showPlayerDetailsView = true
                    selectedPlayerID = item.playerID
                } label: {
                    HStack {
                        Text(item.fullName)
                            .frame(width: nameColumnWidth, alignment: .leading)
                        Text("\(item.gamesPlayed)")
                            .frame(width: statColumnWidth, alignment: .center)
                        Text("\(item.wins)")
                            .frame(width: statColumnWidth, alignment: .center)
                        Text("\(item.losses)")
                            .frame(width: statColumnWidth, alignment: .center)
                        Text("\(item.otLosses)")
                            .frame(width: statColumnWidth, alignment: .center)
                        Text(String(format: "%.2f", item.goalsAgainstPerGame))
                            .frame(width: statColumnWidth, alignment: .center)
                        Text("\(item.shutouts)")
                            .frame(width: statColumnWidth, alignment: .center)
                    }
                }
                .appTextStyle()
                .font(.footnote)
                .padding(.vertical, 5)
                .frame(maxWidth: .infinity, alignment: .leading)
                .cornerRadius(10)
            }
        }
    }
    
    // Sorting the array of fetched skater stats based on the header selected
    private func skaterSortedItems() -> [SimulationSkaterStat] {
        let sortedItems: [SimulationSkaterStat]
        
        switch sortOrder {
        case .none:
            sortedItems = viewModel.simSkaterStats
        case .nameAscending:
            sortedItems = viewModel.simSkaterStats.sorted { $0.fullName < $1.fullName }
        case .nameDescending:
            sortedItems = viewModel.simSkaterStats.sorted { $0.fullName > $1.fullName }
        case .gamesPlayedAscending:
            sortedItems = viewModel.simSkaterStats.sorted { $0.gamesPlayed < $1.gamesPlayed }
        case .gamesPlayedDescending:
            sortedItems = viewModel.simSkaterStats.sorted { $0.gamesPlayed > $1.gamesPlayed }
        case .goalsAscending:
            sortedItems = viewModel.simSkaterStats.sorted { $0.goals < $1.goals }
        case .goalsDescending:
            sortedItems = viewModel.simSkaterStats.sorted { $0.goals > $1.goals }
        case .assistsAscending:
            sortedItems = viewModel.simSkaterStats.sorted { $0.assists < $1.assists }
        case .assistsDescending:
            sortedItems = viewModel.simSkaterStats.sorted { $0.assists > $1.assists }
        case .pointsAscending:
            sortedItems = viewModel.simSkaterStats.sorted { $0.points < $1.points }
        case .pointsDescending:
            sortedItems = viewModel.simSkaterStats.sorted { $0.points > $1.points }
        case .powerPlayGoalsAscending:
            sortedItems = viewModel.simSkaterStats.sorted { $0.powerPlayGoals < $1.powerPlayGoals }
        case .powerPlayGoalsDescending:
            sortedItems = viewModel.simSkaterStats.sorted { $0.powerPlayGoals > $1.powerPlayGoals }
        case .powerPlayPointsAscending:
            sortedItems = viewModel.simSkaterStats.sorted { $0.powerPlayPoints < $1.powerPlayPoints }
        case .powerPlayPointsDescending:
            sortedItems = viewModel.simSkaterStats.sorted { $0.powerPlayPoints > $1.powerPlayPoints }
        default:
            sortedItems = viewModel.simSkaterStats
        }
        
        return Array(sortedItems.prefix(maxRows))
    }
    
    // Sorting the array of fetched goalie stats based on the header selected
    private func goalieSortedItems() -> [SimulationGoalieStat] {
        let sortedItems: [SimulationGoalieStat]
        
        switch sortOrder {
        case .none:
            sortedItems = viewModel.simGoalieStats
        case .nameAscending:
            sortedItems = viewModel.simGoalieStats.sorted { $0.fullName < $1.fullName }
        case .nameDescending:
            sortedItems = viewModel.simGoalieStats.sorted { $0.fullName > $1.fullName }
        case .gamesPlayedAscending:
            sortedItems = viewModel.simGoalieStats.sorted { $0.gamesPlayed < $1.gamesPlayed }
        case .gamesPlayedDescending:
            sortedItems = viewModel.simGoalieStats.sorted { $0.gamesPlayed > $1.gamesPlayed }
        case .winsAscending:
            sortedItems = viewModel.simGoalieStats.sorted { $0.wins < $1.wins }
        case .winsDescending:
            sortedItems = viewModel.simGoalieStats.sorted { $0.wins > $1.wins }
        case .lossesAscending:
            sortedItems = viewModel.simGoalieStats.sorted { $0.losses < $1.losses }
        case .lossesDescending:
            sortedItems = viewModel.simGoalieStats.sorted { $0.losses > $1.losses }
        case .otLossesAscending:
            sortedItems = viewModel.simGoalieStats.sorted { $0.otLosses < $1.otLosses }
        case .otLossesDescending:
            sortedItems = viewModel.simGoalieStats.sorted { $0.otLosses > $1.otLosses }
        case .goalsAgainstPerGameAscending:
            sortedItems = viewModel.simGoalieStats.sorted { $0.goalsAgainstPerGame < $1.goalsAgainstPerGame }
        case .goalsAgainstPerGameDescending:
            sortedItems = viewModel.simGoalieStats.sorted { $0.goalsAgainstPerGame > $1.goalsAgainstPerGame }
        case .shutoutsAscending:
            sortedItems = viewModel.simGoalieStats.sorted { $0.shutouts < $1.shutouts }
        case .shutoutsDescending:
            sortedItems = viewModel.simGoalieStats.sorted { $0.shutouts > $1.shutouts }
        default:
            sortedItems = viewModel.simGoalieStats
        }
        
        return Array(sortedItems.prefix(maxRows))
    }
    
    // Sorting the array of fetched skater playoff stats based on the header selected
    private func skaterPlayoffsSortedItems() -> [SimulationPlayoffSkaterStat] {
        let sortedItems: [SimulationPlayoffSkaterStat]
        
        switch sortOrder {
        case .none:
            sortedItems = viewModel.simSkaterPlayoffStats
        case .nameAscending:
            sortedItems = viewModel.simSkaterPlayoffStats.sorted { $0.fullName < $1.fullName }
        case .nameDescending:
            sortedItems = viewModel.simSkaterPlayoffStats.sorted { $0.fullName > $1.fullName }
        case .gamesPlayedAscending:
            sortedItems = viewModel.simSkaterPlayoffStats.sorted { $0.gamesPlayed < $1.gamesPlayed }
        case .gamesPlayedDescending:
            sortedItems = viewModel.simSkaterPlayoffStats.sorted { $0.gamesPlayed > $1.gamesPlayed }
        case .goalsAscending:
            sortedItems = viewModel.simSkaterPlayoffStats.sorted { $0.goals < $1.goals }
        case .goalsDescending:
            sortedItems = viewModel.simSkaterPlayoffStats.sorted { $0.goals > $1.goals }
        case .assistsAscending:
            sortedItems = viewModel.simSkaterPlayoffStats.sorted { $0.assists < $1.assists }
        case .assistsDescending:
            sortedItems = viewModel.simSkaterPlayoffStats.sorted { $0.assists > $1.assists }
        case .pointsAscending:
            sortedItems = viewModel.simSkaterPlayoffStats.sorted { $0.points < $1.points }
        case .pointsDescending:
            sortedItems = viewModel.simSkaterPlayoffStats.sorted { $0.points > $1.points }
        case .powerPlayGoalsAscending:
            sortedItems = viewModel.simSkaterPlayoffStats.sorted { $0.powerPlayGoals < $1.powerPlayGoals }
        case .powerPlayGoalsDescending:
            sortedItems = viewModel.simSkaterPlayoffStats.sorted { $0.powerPlayGoals > $1.powerPlayGoals }
        case .powerPlayPointsAscending:
            sortedItems = viewModel.simSkaterPlayoffStats.sorted { $0.powerPlayPoints < $1.powerPlayPoints }
        case .powerPlayPointsDescending:
            sortedItems = viewModel.simSkaterPlayoffStats.sorted { $0.powerPlayPoints > $1.powerPlayPoints }
        default:
            sortedItems = viewModel.simSkaterPlayoffStats
        }
        
        return Array(sortedItems.prefix(maxRows))
    }
    
    // Sorting the array of fetched goalie playoffs stats based on the header selected
    private func goaliePlayoffsSortedItems() -> [SimulationPlayoffGoalieStat] {
        let sortedItems: [SimulationPlayoffGoalieStat]
        
        switch sortOrder {
        case .none:
            sortedItems = viewModel.simGoaliePlayoffStats
        case .nameAscending:
            sortedItems = viewModel.simGoaliePlayoffStats.sorted { $0.fullName < $1.fullName }
        case .nameDescending:
            sortedItems = viewModel.simGoaliePlayoffStats.sorted { $0.fullName > $1.fullName }
        case .gamesPlayedAscending:
            sortedItems = viewModel.simGoaliePlayoffStats.sorted { $0.gamesPlayed < $1.gamesPlayed }
        case .gamesPlayedDescending:
            sortedItems = viewModel.simGoaliePlayoffStats.sorted { $0.gamesPlayed > $1.gamesPlayed }
        case .winsAscending:
            sortedItems = viewModel.simGoaliePlayoffStats.sorted { $0.wins < $1.wins }
        case .winsDescending:
            sortedItems = viewModel.simGoaliePlayoffStats.sorted { $0.wins > $1.wins }
        case .lossesAscending:
            sortedItems = viewModel.simGoaliePlayoffStats.sorted { $0.losses < $1.losses }
        case .lossesDescending:
            sortedItems = viewModel.simGoaliePlayoffStats.sorted { $0.losses > $1.losses }
        case .otLossesAscending:
            sortedItems = viewModel.simGoaliePlayoffStats.sorted { $0.otLosses < $1.otLosses }
        case .otLossesDescending:
            sortedItems = viewModel.simGoaliePlayoffStats.sorted { $0.otLosses > $1.otLosses }
        case .goalsAgainstPerGameAscending:
            sortedItems = viewModel.simGoaliePlayoffStats.sorted { $0.goalsAgainstPerGame < $1.goalsAgainstPerGame }
        case .goalsAgainstPerGameDescending:
            sortedItems = viewModel.simGoaliePlayoffStats.sorted { $0.goalsAgainstPerGame > $1.goalsAgainstPerGame }
        case .shutoutsAscending:
            sortedItems = viewModel.simGoaliePlayoffStats.sorted { $0.shutouts < $1.shutouts }
        case .shutoutsDescending:
            sortedItems = viewModel.simGoaliePlayoffStats.sorted { $0.shutouts > $1.shutouts }
        default:
            sortedItems = viewModel.simGoaliePlayoffStats
        }
        
        return Array(sortedItems.prefix(maxRows))
    }
}
