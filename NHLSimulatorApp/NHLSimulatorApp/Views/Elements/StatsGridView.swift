//
//  StatsGridView.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-08-05.
//

import SwiftUI

struct StatsGridView: View {
    @ObservedObject var viewModel: PlayerStatsViewModel
    @Binding var selectedPlayerType: PlayerType
    @State var sortOrder: SortOrder = .pointsDescending
    private let nameColumnWidth: CGFloat = 160
    private let statColumnWidth: CGFloat = 40
    
    var body: some View {
        VStack {
            ScrollView(.vertical) {
                LazyVStack {
                    ScrollView(.horizontal) {
                        VStack {
                            if selectedPlayerType == .skaters {
                                HStack {
                                    GridHeaderView(title: NSLocalizedString(StatColumnHeader.name.rawValue, comment: ""), sortOrder: $sortOrder, skaterKeyPath: \SimulationSkaterStat.fullName, goalieKeyPath: nil)
                                    GridHeaderView(title: NSLocalizedString(StatColumnHeader.gamesPlayed.rawValue, comment: ""), sortOrder: $sortOrder, skaterKeyPath: \SimulationSkaterStat.gamesPlayed, goalieKeyPath: nil)
                                    GridHeaderView(title: NSLocalizedString(StatColumnHeader.goals.rawValue, comment: ""), sortOrder: $sortOrder, skaterKeyPath: \SimulationSkaterStat.goals, goalieKeyPath: nil)
                                    GridHeaderView(title: NSLocalizedString(StatColumnHeader.assists.rawValue, comment: ""), sortOrder: $sortOrder, skaterKeyPath: \SimulationSkaterStat.assists, goalieKeyPath: nil)
                                    GridHeaderView(title: NSLocalizedString(StatColumnHeader.points.rawValue, comment: ""), sortOrder: $sortOrder, skaterKeyPath: \SimulationSkaterStat.points, goalieKeyPath: nil)
                                    GridHeaderView(title: NSLocalizedString(StatColumnHeader.powerPlayGoals.rawValue, comment: ""), sortOrder: $sortOrder, skaterKeyPath: \SimulationSkaterStat.powerPlayGoals, goalieKeyPath: nil)
                                    GridHeaderView(title: NSLocalizedString(StatColumnHeader.powerPlayPoints.rawValue, comment: ""), sortOrder: $sortOrder, skaterKeyPath: \SimulationSkaterStat.powerPlayPoints, goalieKeyPath: nil)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                
                                ForEach(skaterSortedItems(), id: \.self) { item in
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
                                    .appTextStyle()
                                    .font(.footnote)
                                    .padding(.vertical, 5)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .cornerRadius(10)
                                }
                            } else if selectedPlayerType == .goalies {
                                HStack {
                                    GridHeaderView(title: NSLocalizedString(StatColumnHeader.name.rawValue, comment: ""), sortOrder: $sortOrder, skaterKeyPath: nil, goalieKeyPath: \SimulationGoalieStat.fullName)
                                    GridHeaderView(title: NSLocalizedString(StatColumnHeader.gamesPlayed.rawValue, comment: ""), sortOrder: $sortOrder, skaterKeyPath: nil, goalieKeyPath: \SimulationGoalieStat.gamesPlayed)
                                    GridHeaderView(title: NSLocalizedString(StatColumnHeader.wins.rawValue, comment: ""), sortOrder: $sortOrder, skaterKeyPath: nil, goalieKeyPath: \SimulationGoalieStat.wins)
                                    GridHeaderView(title: NSLocalizedString(StatColumnHeader.losses.rawValue, comment: ""), sortOrder: $sortOrder, skaterKeyPath: nil, goalieKeyPath: \SimulationGoalieStat.losses)
                                    GridHeaderView(title: NSLocalizedString(StatColumnHeader.otLosses.rawValue, comment: ""), sortOrder: $sortOrder, skaterKeyPath: nil, goalieKeyPath: \SimulationGoalieStat.otLosses)
                                    GridHeaderView(title: NSLocalizedString(StatColumnHeader.goalsAgainstPerGame.rawValue, comment: ""), sortOrder: $sortOrder, skaterKeyPath: nil, goalieKeyPath: \SimulationGoalieStat.goalsAgainstPerGame)
                                    GridHeaderView(title: NSLocalizedString(StatColumnHeader.shutouts.rawValue, comment: ""), sortOrder: $sortOrder, skaterKeyPath: nil, goalieKeyPath: \SimulationGoalieStat.shutouts)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                
                                ForEach(goalieSortedItems(), id: \.self) { item in
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
    
    private func skaterSortedItems() -> [SimulationSkaterStat] {
        switch sortOrder {
        case .none:
            return viewModel.simSkaterStats
        case .nameAscending:
            return viewModel.simSkaterStats.sorted { $0.fullName < $1.fullName }
        case .nameDescending:
            return viewModel.simSkaterStats.sorted { $0.fullName > $1.fullName }
        case .gamesPlayedAscending:
            return viewModel.simSkaterStats.sorted { $0.gamesPlayed < $1.gamesPlayed }
        case .gamesPlayedDescending:
            return viewModel.simSkaterStats.sorted { $0.gamesPlayed > $1.gamesPlayed }
        case .goalsAscending:
            return viewModel.simSkaterStats.sorted { $0.goals < $1.goals }
        case .goalsDescending:
            return viewModel.simSkaterStats.sorted { $0.goals > $1.goals }
        case .assistsAscending:
            return viewModel.simSkaterStats.sorted { $0.assists < $1.assists }
        case .assistsDescending:
            return viewModel.simSkaterStats.sorted { $0.assists > $1.assists }
        case .pointsAscending:
            return viewModel.simSkaterStats.sorted { $0.points < $1.points }
        case .pointsDescending:
            return viewModel.simSkaterStats.sorted { $0.points > $1.points }
        case .powerPlayGoalsAscending:
            return viewModel.simSkaterStats.sorted { $0.powerPlayGoals < $1.powerPlayGoals }
        case .powerPlayGoalsDescending:
            return viewModel.simSkaterStats.sorted { $0.powerPlayGoals > $1.powerPlayGoals }
        case .powerPlayPointsAscending:
            return viewModel.simSkaterStats.sorted { $0.powerPlayPoints < $1.powerPlayPoints }
        case .powerPlayPointsDescending:
            return viewModel.simSkaterStats.sorted { $0.powerPlayPoints > $1.powerPlayPoints }
        default:
            return viewModel.simSkaterStats
        }
    }
    
    private func goalieSortedItems() -> [SimulationGoalieStat] {
        switch sortOrder {
        case .none:
            return viewModel.simGoalieStats
        case .nameAscending:
            return viewModel.simGoalieStats.sorted { $0.fullName < $1.fullName }
        case .nameDescending:
            return viewModel.simGoalieStats.sorted { $0.fullName > $1.fullName }
        case .gamesPlayedAscending:
            return viewModel.simGoalieStats.sorted { $0.gamesPlayed < $1.gamesPlayed }
        case .gamesPlayedDescending:
            return viewModel.simGoalieStats.sorted { $0.gamesPlayed > $1.gamesPlayed }
        case .winsAscending:
            return viewModel.simGoalieStats.sorted { $0.wins < $1.wins }
        case .winsDescending:
            return viewModel.simGoalieStats.sorted { $0.wins > $1.wins }
        case .lossesAscending:
            return viewModel.simGoalieStats.sorted { $0.losses < $1.losses }
        case .lossesDescending:
            return viewModel.simGoalieStats.sorted { $0.losses > $1.losses }
        case .otLossesAscending:
            return viewModel.simGoalieStats.sorted { $0.otLosses < $1.otLosses }
        case .otLossesDescending:
            return viewModel.simGoalieStats.sorted { $0.otLosses > $1.otLosses }
        case .goalsAgainstPerGameAscending:
            return viewModel.simGoalieStats.sorted { $0.goalsAgainstPerGame < $1.goalsAgainstPerGame }
        case .goalsAgainstPerGameDescending:
            return viewModel.simGoalieStats.sorted { $0.goalsAgainstPerGame > $1.goalsAgainstPerGame }
        case .shutoutsAscending:
            return viewModel.simGoalieStats.sorted { $0.shutouts < $1.shutouts }
        case .shutoutsDescending:
            return viewModel.simGoalieStats.sorted { $0.shutouts > $1.shutouts }
        default:
            return viewModel.simGoalieStats
        }
    }
}

struct GridHeaderView<KeyPathType: Comparable>: View {
    let title: String
    @Binding var sortOrder: SortOrder
    let skaterKeyPath: KeyPath<SimulationSkaterStat, KeyPathType>?
    let goalieKeyPath: KeyPath<SimulationGoalieStat, KeyPathType>?
    private let nameColumnWidth: CGFloat = 160
    private let statColumnWidth: CGFloat = 40
    
    var body: some View {
        Button(action: {
            toggleSortOrder()
        }) {
            HStack {
                Text(title)
            }
            .appTextStyle()
            .font(.footnote)
            .frame(width: title == NSLocalizedString(StatColumnHeader.name.rawValue, comment: "") ? nameColumnWidth : statColumnWidth, alignment: title == NSLocalizedString(StatColumnHeader.name.rawValue, comment: "") ? .leading : .center)
        }
    }
    
    private func toggleSortOrder() {
        switch title {
        case NSLocalizedString(StatColumnHeader.name.rawValue, comment: ""):
            sortOrder = sortOrder == .nameAscending ? .nameDescending : .nameAscending
        case NSLocalizedString(StatColumnHeader.gamesPlayed.rawValue, comment: ""):
            sortOrder = sortOrder == .gamesPlayedAscending ? .gamesPlayedDescending : .gamesPlayedAscending
        case NSLocalizedString(StatColumnHeader.goals.rawValue, comment: ""):
            sortOrder = sortOrder == .goalsAscending ? .goalsDescending : .goalsAscending
        case NSLocalizedString(StatColumnHeader.assists.rawValue, comment: ""):
            sortOrder = sortOrder == .assistsAscending ? .assistsDescending : .assistsAscending
        case NSLocalizedString(StatColumnHeader.points.rawValue, comment: ""):
            sortOrder = sortOrder == .pointsAscending ? .pointsDescending : .pointsAscending
        case NSLocalizedString(StatColumnHeader.powerPlayGoals.rawValue, comment: ""):
            sortOrder = sortOrder == .powerPlayGoalsAscending ? .powerPlayGoalsDescending : .powerPlayGoalsAscending
        case NSLocalizedString(StatColumnHeader.powerPlayPoints.rawValue, comment: ""):
            sortOrder = sortOrder == .powerPlayPointsAscending ? .powerPlayPointsDescending : .powerPlayPointsAscending
        case NSLocalizedString(StatColumnHeader.wins.rawValue, comment: ""):
            sortOrder = sortOrder == .winsAscending ? .winsDescending : .winsAscending
        case NSLocalizedString(StatColumnHeader.losses.rawValue, comment: ""):
            sortOrder = sortOrder == .lossesAscending ? .lossesDescending : .lossesAscending
        case NSLocalizedString(StatColumnHeader.otLosses.rawValue, comment: ""):
            sortOrder = sortOrder == .otLossesAscending ? .otLossesDescending : .otLossesAscending
        case NSLocalizedString(StatColumnHeader.goalsAgainstPerGame.rawValue, comment: ""):
            sortOrder = sortOrder == .goalsAgainstPerGameAscending ? .goalsAgainstPerGameDescending : .goalsAgainstPerGameAscending
        case NSLocalizedString(StatColumnHeader.shutouts.rawValue, comment: ""):
            sortOrder = sortOrder == .shutoutsAscending ? .shutoutsDescending : .shutoutsAscending
        default:
            sortOrder = .none
        }
    }
    
    private func currentSortOrder() -> SortOrder {
        switch title {
        case NSLocalizedString(StatColumnHeader.name.rawValue, comment: ""):
            return sortOrder == .nameAscending ? .nameAscending : (sortOrder == .nameDescending ? .nameDescending : .none)
        case NSLocalizedString(StatColumnHeader.gamesPlayed.rawValue, comment: ""):
            return sortOrder == .gamesPlayedAscending ? .gamesPlayedAscending : (sortOrder == .gamesPlayedDescending ? .gamesPlayedDescending : .none)
        case NSLocalizedString(StatColumnHeader.goals.rawValue, comment: ""):
            return sortOrder == .goalsAscending ? .goalsAscending : (sortOrder == .goalsDescending ? .goalsDescending : .none)
        case NSLocalizedString(StatColumnHeader.assists.rawValue, comment: ""):
            return sortOrder == .assistsAscending ? .assistsAscending : (sortOrder == .assistsDescending ? .assistsDescending : .none)
        case NSLocalizedString(StatColumnHeader.points.rawValue, comment: ""):
            return sortOrder == .pointsAscending ? .pointsAscending : (sortOrder == .pointsDescending ? .pointsDescending : .none)
        case NSLocalizedString(StatColumnHeader.powerPlayGoals.rawValue, comment: ""):
            return sortOrder == .powerPlayGoalsAscending ? .powerPlayGoalsAscending : (sortOrder == .powerPlayGoalsDescending ? .powerPlayGoalsDescending : .none)
        case NSLocalizedString(StatColumnHeader.powerPlayPoints.rawValue, comment: ""):
            return sortOrder == .powerPlayPointsAscending ? .powerPlayPointsAscending : (sortOrder == .powerPlayPointsDescending ? .powerPlayPointsDescending : .none)
        case NSLocalizedString(StatColumnHeader.wins.rawValue, comment: ""):
            return sortOrder == .winsAscending ? .winsAscending : (sortOrder == .winsDescending ? .winsDescending : .none)
        case NSLocalizedString(StatColumnHeader.losses.rawValue, comment: ""):
            return sortOrder == .lossesAscending ? .lossesAscending : (sortOrder == .lossesDescending ? .lossesDescending : .none)
        case NSLocalizedString(StatColumnHeader.otLosses.rawValue, comment: ""):
            return sortOrder == .otLossesAscending ? .otLossesAscending : (sortOrder == .otLossesDescending ? .otLossesDescending : .none)
        case NSLocalizedString(StatColumnHeader.goalsAgainstPerGame.rawValue, comment: ""):
            return sortOrder == .goalsAgainstPerGameAscending ? .goalsAgainstPerGameAscending : (sortOrder == .goalsAgainstPerGameDescending ? .goalsAgainstPerGameDescending : .none)
        case NSLocalizedString(StatColumnHeader.shutouts.rawValue, comment: ""):
            return sortOrder == .shutoutsAscending ? .shutoutsAscending : (sortOrder == .shutoutsDescending ? .shutoutsDescending : .none)
        default:
            return .none
        }
    }
}
