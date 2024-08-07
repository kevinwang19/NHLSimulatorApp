//
//  TeamStatsGridView.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-08-06.
//

import SwiftUI

struct TeamStatsGridView: View {
    @ObservedObject var viewModel: TeamStandingsViewModel
    @Binding var rankType: RankType
    @State var sortOrder: SortOrder = .rankAscending
    private let nameColumnWidth: CGFloat = 180
    private let statColumnWidth: CGFloat = 40
    
    var body: some View {
        VStack {
            ScrollView(.vertical) {
                LazyVStack {
                    ScrollView(.horizontal) {
                        VStack {
                            HStack {
                                // Grid header titles and sorting paths for team standings stats
                                HStack {
                                    GridHeaderView(title: NSLocalizedString(StatColumnHeader.rank.rawValue, comment: ""), sortOrder: $sortOrder, skaterKeyPath: nil, goalieKeyPath: nil, teamKeyPath: (rankType == .league ? \SimulationTeamStat.leagueRank : (rankType == .conference ? \SimulationTeamStat.conferenceRank : \SimulationTeamStat.divisionRank)))
                                    GridHeaderView(title: NSLocalizedString(StatColumnHeader.name.rawValue, comment: ""), sortOrder: $sortOrder, skaterKeyPath: nil, goalieKeyPath: nil, teamKeyPath: \SimulationTeamStat.fullName)
                                    GridHeaderView(title: NSLocalizedString(StatColumnHeader.gamesPlayed.rawValue, comment: ""), sortOrder: $sortOrder, skaterKeyPath: nil, goalieKeyPath: nil, teamKeyPath: \SimulationTeamStat.gamesPlayed)
                                    GridHeaderView(title: NSLocalizedString(StatColumnHeader.wins.rawValue, comment: ""), sortOrder: $sortOrder, skaterKeyPath: nil, goalieKeyPath: nil, teamKeyPath: \SimulationTeamStat.wins)
                                    GridHeaderView(title: NSLocalizedString(StatColumnHeader.losses.rawValue, comment: ""), sortOrder: $sortOrder, skaterKeyPath: nil, goalieKeyPath: nil, teamKeyPath: \SimulationTeamStat.losses)
                                    GridHeaderView(title: NSLocalizedString(StatColumnHeader.otLosses.rawValue, comment: ""), sortOrder: $sortOrder, skaterKeyPath: nil, goalieKeyPath: nil, teamKeyPath: \SimulationTeamStat.otLosses)
                                    GridHeaderView(title: NSLocalizedString(StatColumnHeader.points.rawValue, comment: ""), sortOrder: $sortOrder, skaterKeyPath: nil, goalieKeyPath: nil, teamKeyPath: \SimulationTeamStat.points)
                                    GridHeaderView(title: NSLocalizedString(StatColumnHeader.goalsFor.rawValue, comment: ""), sortOrder: $sortOrder, skaterKeyPath: nil, goalieKeyPath: nil, teamKeyPath: \SimulationTeamStat.goalsFor)
                                    GridHeaderView(title: NSLocalizedString(StatColumnHeader.goalsForPerGame.rawValue, comment: ""), sortOrder: $sortOrder, skaterKeyPath: nil, goalieKeyPath: nil, teamKeyPath: \SimulationTeamStat.goalsForPerGame)
                                    GridHeaderView(title: NSLocalizedString(StatColumnHeader.goalsAgainst.rawValue, comment: ""), sortOrder: $sortOrder, skaterKeyPath: nil, goalieKeyPath: nil, teamKeyPath: \SimulationTeamStat.goalsAgainst)
                                }
                                HStack {
                                    GridHeaderView(title: NSLocalizedString(StatColumnHeader.goalsAgainstPerGame.rawValue, comment: ""), sortOrder: $sortOrder, skaterKeyPath: nil, goalieKeyPath: nil, teamKeyPath: \SimulationTeamStat.goalsAgainstPerGame)
                                    GridHeaderView(title: NSLocalizedString(StatColumnHeader.powerplayPctg.rawValue, comment: ""), sortOrder: $sortOrder, skaterKeyPath: nil, goalieKeyPath: nil, teamKeyPath: \SimulationTeamStat.powerPlayPctg)
                                    GridHeaderView(title: NSLocalizedString(StatColumnHeader.penaltyKillPctg.rawValue, comment: ""), sortOrder: $sortOrder, skaterKeyPath: nil, goalieKeyPath: nil, teamKeyPath: \SimulationTeamStat.penaltyKillPctg)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            // Rows of team standings stats data
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
                        }
                    }
                }
                .padding(Spacing.spacingExtraSmall)
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
}
