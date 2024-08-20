//
//  TeamSortableStatsGridView.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-08-06.
//

import SwiftUI

struct TeamSortableStatsGridView: View {
    @ObservedObject var viewModel: TeamStandingsViewModel
    @Binding var selectedGameType: GameType
    @Binding var rankType: RankType
    @State var sortOrder: SortOrder = .rankAscending
    private let nameColumnWidth: CGFloat = 180
    private let statColumnWidth: CGFloat = 50
    
    var body: some View {
        VStack {
            ScrollView(.vertical) {
                LazyVStack {
                    ScrollView(.horizontal) {
                        VStack {
                            teamStatsHeader()
                            teamStatsRows()
                        }
                    }
                }
                .padding(Spacing.spacingExtraSmall)
            }
        }
        .onAppear {
            if selectedGameType == .playoffs {
                sortOrder = .winsDescending
            } else {
                sortOrder = .rankAscending
            }
        }
    }
    
    // Team stats header view
    @ViewBuilder
    private func teamStatsHeader() -> some View {
        if selectedGameType == .regular {
            HStack {
                HStack {
                    GridHeaderView(title: StatColumnHeader.rank.localizedString, sortOrder: $sortOrder, skaterKeyPath: nil, goalieKeyPath: nil, teamKeyPath: (rankType == .league ? \SimulationTeamStat.leagueRank : (rankType == .conference ? \SimulationTeamStat.conferenceRank : \SimulationTeamStat.divisionRank)))
                    GridHeaderView(title: StatColumnHeader.name.localizedString, sortOrder: $sortOrder, skaterKeyPath: nil, goalieKeyPath: nil, teamKeyPath: \SimulationTeamStat.fullName)
                    GridHeaderView(title: StatColumnHeader.gamesPlayed.localizedString, sortOrder: $sortOrder, skaterKeyPath: nil, goalieKeyPath: nil, teamKeyPath: \SimulationTeamStat.gamesPlayed)
                    GridHeaderView(title: StatColumnHeader.wins.localizedString, sortOrder: $sortOrder, skaterKeyPath: nil, goalieKeyPath: nil, teamKeyPath: \SimulationTeamStat.wins)
                    GridHeaderView(title: StatColumnHeader.losses.localizedString, sortOrder: $sortOrder, skaterKeyPath: nil, goalieKeyPath: nil, teamKeyPath: \SimulationTeamStat.losses)
                    GridHeaderView(title: StatColumnHeader.otLosses.localizedString, sortOrder: $sortOrder, skaterKeyPath: nil, goalieKeyPath: nil, teamKeyPath: \SimulationTeamStat.otLosses)
                    GridHeaderView(title: StatColumnHeader.points.localizedString, sortOrder: $sortOrder, skaterKeyPath: nil, goalieKeyPath: nil, teamKeyPath: \SimulationTeamStat.points)
                    GridHeaderView(title: StatColumnHeader.goalsFor.localizedString, sortOrder: $sortOrder, skaterKeyPath: nil, goalieKeyPath: nil, teamKeyPath: \SimulationTeamStat.goalsFor)
                    GridHeaderView(title: StatColumnHeader.goalsForPerGame.localizedString, sortOrder: $sortOrder, skaterKeyPath: nil, goalieKeyPath: nil, teamKeyPath: \SimulationTeamStat.goalsForPerGame)
                    GridHeaderView(title: StatColumnHeader.goalsAgainst.localizedString, sortOrder: $sortOrder, skaterKeyPath: nil, goalieKeyPath: nil, teamKeyPath: \SimulationTeamStat.goalsAgainst)
                }
                HStack {
                    GridHeaderView(title: StatColumnHeader.goalsAgainstPerGame.localizedString, sortOrder: $sortOrder, skaterKeyPath: nil, goalieKeyPath: nil, teamKeyPath: \SimulationTeamStat.goalsAgainstPerGame)
                    GridHeaderView(title: StatColumnHeader.powerplayPctg.localizedString, sortOrder: $sortOrder, skaterKeyPath: nil, goalieKeyPath: nil, teamKeyPath: \SimulationTeamStat.powerPlayPctg)
                    GridHeaderView(title: StatColumnHeader.penaltyKillPctg.localizedString, sortOrder: $sortOrder, skaterKeyPath: nil, goalieKeyPath: nil, teamKeyPath: \SimulationTeamStat.penaltyKillPctg)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            HStack {
                HStack {
                    GridHeaderView(title: StatColumnHeader.name.localizedString, sortOrder: $sortOrder, skaterKeyPath: nil, goalieKeyPath: nil, teamKeyPath: \SimulationTeamStat.fullName)
                    GridHeaderView(title: StatColumnHeader.gamesPlayed.localizedString, sortOrder: $sortOrder, skaterKeyPath: nil, goalieKeyPath: nil, teamKeyPath: \SimulationTeamStat.gamesPlayed)
                    GridHeaderView(title: StatColumnHeader.wins.localizedString, sortOrder: $sortOrder, skaterKeyPath: nil, goalieKeyPath: nil, teamKeyPath: \SimulationTeamStat.wins)
                    GridHeaderView(title: StatColumnHeader.losses.localizedString, sortOrder: $sortOrder, skaterKeyPath: nil, goalieKeyPath: nil, teamKeyPath: \SimulationTeamStat.losses)
                    GridHeaderView(title: StatColumnHeader.otLosses.localizedString, sortOrder: $sortOrder, skaterKeyPath: nil, goalieKeyPath: nil, teamKeyPath: \SimulationTeamStat.otLosses)
                    GridHeaderView(title: StatColumnHeader.goalsFor.localizedString, sortOrder: $sortOrder, skaterKeyPath: nil, goalieKeyPath: nil, teamKeyPath: \SimulationTeamStat.goalsFor)
                    GridHeaderView(title: StatColumnHeader.goalsForPerGame.localizedString, sortOrder: $sortOrder, skaterKeyPath: nil, goalieKeyPath: nil, teamKeyPath: \SimulationTeamStat.goalsForPerGame)
                    GridHeaderView(title: StatColumnHeader.goalsAgainst.localizedString, sortOrder: $sortOrder, skaterKeyPath: nil, goalieKeyPath: nil, teamKeyPath: \SimulationTeamStat.goalsAgainst)
                }
                HStack {
                    GridHeaderView(title: StatColumnHeader.goalsAgainstPerGame.localizedString, sortOrder: $sortOrder, skaterKeyPath: nil, goalieKeyPath: nil, teamKeyPath: \SimulationTeamStat.goalsAgainstPerGame)
                    GridHeaderView(title: StatColumnHeader.powerplayPctg.localizedString, sortOrder: $sortOrder, skaterKeyPath: nil, goalieKeyPath: nil, teamKeyPath: \SimulationTeamStat.powerPlayPctg)
                    GridHeaderView(title: StatColumnHeader.penaltyKillPctg.localizedString, sortOrder: $sortOrder, skaterKeyPath: nil, goalieKeyPath: nil, teamKeyPath: \SimulationTeamStat.penaltyKillPctg)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    // Team stats rows view
    @ViewBuilder
    private func teamStatsRows() -> some View {
        if selectedGameType == .regular {
            ForEach(teamSortedItems(), id: \.self) { item in
                HStack {
                    HStack {
                        let rank = rankType == .league ? item.leagueRank : (rankType == .conference ? item.conferenceRank : item.divisionRank)
                        Text(" \(rank)")
                            .frame(width: statColumnWidth, alignment: .center)
                        Text(item.fullName + (item.isWildCard ? " " + Symbols.wildcard.rawValue : "") + (item.isPresidents ? " " + Symbols.presidents.rawValue : ""))
                            .frame(width: nameColumnWidth, alignment: .leading)
                        Text("\(item.gamesPlayed)")
                            .frame(width: statColumnWidth, alignment: .center)
                        Text("\(item.wins)")
                            .frame(width: statColumnWidth, alignment: .center)
                        Text("\(item.losses)")
                            .frame(width: statColumnWidth, alignment: .center)
                        Text("\(item.otLosses)")
                            .frame(width: statColumnWidth, alignment: .center)
                        Text("\(item.points)")
                            .frame(width: statColumnWidth, alignment: .center)
                    }
                    HStack {
                        Text("\(item.goalsFor)")
                            .frame(width: statColumnWidth, alignment: .center)
                        Text(String(format: "%.2f", item.goalsForPerGame))
                            .frame(width: statColumnWidth, alignment: .center)
                        Text("\(item.goalsAgainst)")
                            .frame(width: statColumnWidth, alignment: .center)
                        Text(String(format: "%.2f", item.goalsAgainstPerGame))
                            .frame(width: statColumnWidth, alignment: .center)
                        Text(String(format: "%.2f", item.powerPlayPctg * 100))
                            .frame(width: statColumnWidth, alignment: .center)
                        Text(String(format: "%.2f", item.penaltyKillPctg * 100))
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
            ForEach(teamPlayoffsSortedItems(), id: \.self) { item in
                HStack {
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
                    }
                    HStack {
                        Text("\(item.goalsFor)")
                            .frame(width: statColumnWidth, alignment: .center)
                        Text(String(format: "%.2f", item.goalsForPerGame))
                            .frame(width: statColumnWidth, alignment: .center)
                        Text("\(item.goalsAgainst)")
                            .frame(width: statColumnWidth, alignment: .center)
                        Text(String(format: "%.2f", item.goalsAgainstPerGame))
                            .frame(width: statColumnWidth, alignment: .center)
                        Text(String(format: "%.2f", item.powerPlayPctg * 100))
                            .frame(width: statColumnWidth, alignment: .center)
                        Text(String(format: "%.2f", item.penaltyKillPctg * 100))
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
    
    // Sorting the array of fetched team stats based on the header selected
    private func teamSortedItems() -> [SimulationTeamStat] {
        switch sortOrder {
        case .none:
            return viewModel.simTeamStats
        case .rankAscending:
            if rankType == .league {
                return viewModel.simTeamStats.sorted { $0.leagueRank < $1.leagueRank }
            } else if rankType == .conference {
                return viewModel.simTeamStats.sorted { $0.conferenceRank < $1.conferenceRank }
            } else if rankType == .division {
                return viewModel.simTeamStats.sorted { $0.divisionRank < $1.divisionRank }
            } else {
                return viewModel.simTeamStats.sorted { $0.leagueRank < $1.leagueRank }
            }
        case .rankDescending:
            if rankType == .league {
                return viewModel.simTeamStats.sorted { $0.leagueRank > $1.leagueRank }
            } else if rankType == .conference {
                return viewModel.simTeamStats.sorted { $0.conferenceRank > $1.conferenceRank }
            } else if rankType == .division {
                return viewModel.simTeamStats.sorted { $0.divisionRank > $1.divisionRank }
            } else {
                return viewModel.simTeamStats.sorted { $0.leagueRank > $1.leagueRank }
            }
        case .nameAscending:
            return viewModel.simTeamStats.sorted { $0.fullName < $1.fullName }
        case .nameDescending:
            return viewModel.simTeamStats.sorted { $0.fullName > $1.fullName }
        case .gamesPlayedAscending:
            return viewModel.simTeamStats.sorted { $0.gamesPlayed < $1.gamesPlayed }
        case .gamesPlayedDescending:
            return viewModel.simTeamStats.sorted { $0.gamesPlayed > $1.gamesPlayed }
        case .winsAscending:
            return viewModel.simTeamStats.sorted { $0.wins < $1.wins }
        case .winsDescending:
            return viewModel.simTeamStats.sorted { $0.wins > $1.wins }
        case .lossesAscending:
            return viewModel.simTeamStats.sorted { $0.losses < $1.losses }
        case .lossesDescending:
            return viewModel.simTeamStats.sorted { $0.losses > $1.losses }
        case .otLossesAscending:
            return viewModel.simTeamStats.sorted { $0.otLosses < $1.otLosses }
        case .otLossesDescending:
            return viewModel.simTeamStats.sorted { $0.otLosses > $1.otLosses }
        case .pointsAscending:
            return viewModel.simTeamStats.sorted { $0.points < $1.points }
        case .pointsDescending:
            return viewModel.simTeamStats.sorted { $0.points > $1.points }
        case .goalsForAscending:
            return viewModel.simTeamStats.sorted { $0.goalsFor < $1.goalsFor }
        case .goalsForDescending:
            return viewModel.simTeamStats.sorted { $0.goalsFor > $1.goalsFor }
        case .goalsForPerGameAscending:
            return viewModel.simTeamStats.sorted { $0.goalsForPerGame < $1.goalsForPerGame }
        case .goalsForPerGameDescending:
            return viewModel.simTeamStats.sorted { $0.goalsForPerGame > $1.goalsForPerGame }
        case .goalsAgainstAscending:
            return viewModel.simTeamStats.sorted { $0.goalsAgainst < $1.goalsAgainst }
        case .goalsAgainstDescending:
            return viewModel.simTeamStats.sorted { $0.goalsAgainst > $1.goalsAgainst }
        case .goalsAgainstPerGameAscending:
            return viewModel.simTeamStats.sorted { $0.goalsAgainstPerGame < $1.goalsAgainstPerGame }
        case .goalsAgainstPerGameDescending:
            return viewModel.simTeamStats.sorted { $0.goalsAgainstPerGame > $1.goalsAgainstPerGame }
        case .powerplayPctgAscending:
            return viewModel.simTeamStats.sorted { $0.powerPlayPctg < $1.powerPlayPctg }
        case .powerplayPctgDescending:
            return viewModel.simTeamStats.sorted { $0.powerPlayPctg > $1.powerPlayPctg }
        case .penaltyKillPctgAscending:
            return viewModel.simTeamStats.sorted { $0.penaltyKillPctg < $1.penaltyKillPctg }
        case .penaltyKillPctgDescending:
            return viewModel.simTeamStats.sorted { $0.penaltyKillPctg > $1.penaltyKillPctg }
        default:
            return viewModel.simTeamStats
        }
    }
    
    // Sorting the array of fetched team playoff stats based on the header selected
    private func teamPlayoffsSortedItems() -> [SimulationPlayoffTeamStat] {
        switch sortOrder {
        case .none:
            return viewModel.simTeamPlayoffStats
        case .nameAscending:
            return viewModel.simTeamPlayoffStats.sorted { $0.fullName < $1.fullName }
        case .nameDescending:
            return viewModel.simTeamPlayoffStats.sorted { $0.fullName > $1.fullName }
        case .gamesPlayedAscending:
            return viewModel.simTeamPlayoffStats.sorted { $0.gamesPlayed < $1.gamesPlayed }
        case .gamesPlayedDescending:
            return viewModel.simTeamPlayoffStats.sorted { $0.gamesPlayed > $1.gamesPlayed }
        case .winsAscending:
            return viewModel.simTeamPlayoffStats.sorted { $0.wins < $1.wins }
        case .winsDescending:
            return viewModel.simTeamPlayoffStats.sorted { $0.wins > $1.wins }
        case .lossesAscending:
            return viewModel.simTeamPlayoffStats.sorted { $0.losses < $1.losses }
        case .lossesDescending:
            return viewModel.simTeamPlayoffStats.sorted { $0.losses > $1.losses }
        case .otLossesAscending:
            return viewModel.simTeamPlayoffStats.sorted { $0.otLosses < $1.otLosses }
        case .otLossesDescending:
            return viewModel.simTeamPlayoffStats.sorted { $0.otLosses > $1.otLosses }
        case .goalsForAscending:
            return viewModel.simTeamPlayoffStats.sorted { $0.goalsFor < $1.goalsFor }
        case .goalsForDescending:
            return viewModel.simTeamPlayoffStats.sorted { $0.goalsFor > $1.goalsFor }
        case .goalsForPerGameAscending:
            return viewModel.simTeamPlayoffStats.sorted { $0.goalsForPerGame < $1.goalsForPerGame }
        case .goalsForPerGameDescending:
            return viewModel.simTeamPlayoffStats.sorted { $0.goalsForPerGame > $1.goalsForPerGame }
        case .goalsAgainstAscending:
            return viewModel.simTeamPlayoffStats.sorted { $0.goalsAgainst < $1.goalsAgainst }
        case .goalsAgainstDescending:
            return viewModel.simTeamPlayoffStats.sorted { $0.goalsAgainst > $1.goalsAgainst }
        case .goalsAgainstPerGameAscending:
            return viewModel.simTeamPlayoffStats.sorted { $0.goalsAgainstPerGame < $1.goalsAgainstPerGame }
        case .goalsAgainstPerGameDescending:
            return viewModel.simTeamPlayoffStats.sorted { $0.goalsAgainstPerGame > $1.goalsAgainstPerGame }
        case .powerplayPctgAscending:
            return viewModel.simTeamPlayoffStats.sorted { $0.powerPlayPctg < $1.powerPlayPctg }
        case .powerplayPctgDescending:
            return viewModel.simTeamPlayoffStats.sorted { $0.powerPlayPctg > $1.powerPlayPctg }
        case .penaltyKillPctgAscending:
            return viewModel.simTeamPlayoffStats.sorted { $0.penaltyKillPctg < $1.penaltyKillPctg }
        case .penaltyKillPctgDescending:
            return viewModel.simTeamPlayoffStats.sorted { $0.penaltyKillPctg > $1.penaltyKillPctg }
        default:
            return viewModel.simTeamPlayoffStats
        }
    }
}
