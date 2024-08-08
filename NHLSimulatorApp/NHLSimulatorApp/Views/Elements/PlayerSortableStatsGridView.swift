//
//  PlayerSortableStatsGridView.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-08-05.
//

import SwiftUI

struct PlayerSortableStatsGridView: View {
    @ObservedObject var viewModel: PlayerStatsViewModel
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
                                // Grid header titles and sorting paths for skater stats
                                HStack {
                                    GridHeaderView(title: NSLocalizedString(StatColumnHeader.name.rawValue, comment: ""), sortOrder: $sortOrder, skaterKeyPath: \SimulationSkaterStat.fullName, goalieKeyPath: nil, teamKeyPath: nil)
                                    GridHeaderView(title: NSLocalizedString(StatColumnHeader.gamesPlayed.rawValue, comment: ""), sortOrder: $sortOrder, skaterKeyPath: \SimulationSkaterStat.gamesPlayed, goalieKeyPath: nil, teamKeyPath: nil)
                                    GridHeaderView(title: NSLocalizedString(StatColumnHeader.goals.rawValue, comment: ""), sortOrder: $sortOrder, skaterKeyPath: \SimulationSkaterStat.goals, goalieKeyPath: nil, teamKeyPath: nil)
                                    GridHeaderView(title: NSLocalizedString(StatColumnHeader.assists.rawValue, comment: ""), sortOrder: $sortOrder, skaterKeyPath: \SimulationSkaterStat.assists, goalieKeyPath: nil, teamKeyPath: nil)
                                    GridHeaderView(title: NSLocalizedString(StatColumnHeader.points.rawValue, comment: ""), sortOrder: $sortOrder, skaterKeyPath: \SimulationSkaterStat.points, goalieKeyPath: nil, teamKeyPath: nil)
                                    GridHeaderView(title: NSLocalizedString(StatColumnHeader.powerPlayGoals.rawValue, comment: ""), sortOrder: $sortOrder, skaterKeyPath: \SimulationSkaterStat.powerPlayGoals, goalieKeyPath: nil, teamKeyPath: nil)
                                    GridHeaderView(title: NSLocalizedString(StatColumnHeader.powerPlayPoints.rawValue, comment: ""), sortOrder: $sortOrder, skaterKeyPath: \SimulationSkaterStat.powerPlayPoints, goalieKeyPath: nil, teamKeyPath: nil)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                
                                // Rows of skater stats data
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
                            } else if selectedPlayerType == .goalies {
                                // Grid header titles and sorting paths for goalie stats
                                HStack {
                                    GridHeaderView(title: NSLocalizedString(StatColumnHeader.name.rawValue, comment: ""), sortOrder: $sortOrder, skaterKeyPath: nil, goalieKeyPath: \SimulationGoalieStat.fullName, teamKeyPath: nil)
                                    GridHeaderView(title: NSLocalizedString(StatColumnHeader.gamesPlayed.rawValue, comment: ""), sortOrder: $sortOrder, skaterKeyPath: nil, goalieKeyPath: \SimulationGoalieStat.gamesPlayed, teamKeyPath: nil)
                                    GridHeaderView(title: NSLocalizedString(StatColumnHeader.wins.rawValue, comment: ""), sortOrder: $sortOrder, skaterKeyPath: nil, goalieKeyPath: \SimulationGoalieStat.wins, teamKeyPath: nil)
                                    GridHeaderView(title: NSLocalizedString(StatColumnHeader.losses.rawValue, comment: ""), sortOrder: $sortOrder, skaterKeyPath: nil, goalieKeyPath: \SimulationGoalieStat.losses, teamKeyPath: nil)
                                    GridHeaderView(title: NSLocalizedString(StatColumnHeader.otLosses.rawValue, comment: ""), sortOrder: $sortOrder, skaterKeyPath: nil, goalieKeyPath: \SimulationGoalieStat.otLosses, teamKeyPath: nil)
                                    GridHeaderView(title: NSLocalizedString(StatColumnHeader.goalsAgainstPerGame.rawValue, comment: ""), sortOrder: $sortOrder, skaterKeyPath: nil, goalieKeyPath: \SimulationGoalieStat.goalsAgainstPerGame, teamKeyPath: nil)
                                    GridHeaderView(title: NSLocalizedString(StatColumnHeader.shutouts.rawValue, comment: ""), sortOrder: $sortOrder, skaterKeyPath: nil, goalieKeyPath: \SimulationGoalieStat.shutouts, teamKeyPath: nil)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                
                                // Rows of goalie stats data
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
}
