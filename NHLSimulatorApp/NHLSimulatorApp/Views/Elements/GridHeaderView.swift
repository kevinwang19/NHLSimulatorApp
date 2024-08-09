//
//  GridHeaderView.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-08-06.
//

import SwiftUI

struct GridHeaderView<KeyPathType: Comparable>: View {
    let title: String
    @Binding var sortOrder: SortOrder
    let skaterKeyPath: KeyPath<SimulationSkaterStat, KeyPathType>?
    let goalieKeyPath: KeyPath<SimulationGoalieStat, KeyPathType>?
    let teamKeyPath: KeyPath<SimulationTeamStat, KeyPathType>?
    private let nameColumnWidth: CGFloat = 180
    private let statColumnWidth: CGFloat = 50
    
    var body: some View {
        // Clicking the header toggles the sorting
        Button(action: {
            toggleSortOrder()
        }) {
            HStack {
                Text(title)
            }
            .appTextStyle()
            .font(.footnote)
            .frame(width: title == StatColumnHeader.name.localizedString ? nameColumnWidth : statColumnWidth, alignment: title == StatColumnHeader.name.localizedString ? .leading : .center)
        }
    }
    
    // Determine whether the clicking the header will sort the stat in ascending or descending order
    private func toggleSortOrder() {
        switch title {
        case StatColumnHeader.name.localizedString:
            sortOrder = sortOrder == .nameAscending ? .nameDescending : .nameAscending
        case StatColumnHeader.gamesPlayed.localizedString:
            sortOrder = sortOrder == .gamesPlayedAscending ? .gamesPlayedDescending : .gamesPlayedAscending
        case StatColumnHeader.goals.localizedString:
            sortOrder = sortOrder == .goalsAscending ? .goalsDescending : .goalsAscending
        case StatColumnHeader.assists.localizedString:
            sortOrder = sortOrder == .assistsAscending ? .assistsDescending : .assistsAscending
        case StatColumnHeader.points.localizedString:
            sortOrder = sortOrder == .pointsAscending ? .pointsDescending : .pointsAscending
        case StatColumnHeader.powerPlayGoals.localizedString:
            sortOrder = sortOrder == .powerPlayGoalsAscending ? .powerPlayGoalsDescending : .powerPlayGoalsAscending
        case StatColumnHeader.powerPlayPoints.localizedString:
            sortOrder = sortOrder == .powerPlayPointsAscending ? .powerPlayPointsDescending : .powerPlayPointsAscending
        case StatColumnHeader.wins.localizedString:
            sortOrder = sortOrder == .winsAscending ? .winsDescending : .winsAscending
        case StatColumnHeader.losses.localizedString:
            sortOrder = sortOrder == .lossesAscending ? .lossesDescending : .lossesAscending
        case StatColumnHeader.otLosses.localizedString:
            sortOrder = sortOrder == .otLossesAscending ? .otLossesDescending : .otLossesAscending
        case StatColumnHeader.goalsAgainstPerGame.localizedString:
            sortOrder = sortOrder == .goalsAgainstPerGameAscending ? .goalsAgainstPerGameDescending : .goalsAgainstPerGameAscending
        case StatColumnHeader.shutouts.localizedString:
            sortOrder = sortOrder == .shutoutsAscending ? .shutoutsDescending : .shutoutsAscending
        default:
            sortOrder = .none
        }
    }
    
    // Determine whether the current stat is ascending or descending
    private func currentSortOrder() -> SortOrder {
        switch title {
        case StatColumnHeader.name.localizedString:
            return sortOrder == .nameAscending ? .nameAscending : (sortOrder == .nameDescending ? .nameDescending : .none)
        case StatColumnHeader.gamesPlayed.localizedString:
            return sortOrder == .gamesPlayedAscending ? .gamesPlayedAscending : (sortOrder == .gamesPlayedDescending ? .gamesPlayedDescending : .none)
        case StatColumnHeader.goals.localizedString:
            return sortOrder == .goalsAscending ? .goalsAscending : (sortOrder == .goalsDescending ? .goalsDescending : .none)
        case StatColumnHeader.assists.localizedString:
            return sortOrder == .assistsAscending ? .assistsAscending : (sortOrder == .assistsDescending ? .assistsDescending : .none)
        case StatColumnHeader.points.localizedString:
            return sortOrder == .pointsAscending ? .pointsAscending : (sortOrder == .pointsDescending ? .pointsDescending : .none)
        case StatColumnHeader.powerPlayGoals.localizedString:
            return sortOrder == .powerPlayGoalsAscending ? .powerPlayGoalsAscending : (sortOrder == .powerPlayGoalsDescending ? .powerPlayGoalsDescending : .none)
        case StatColumnHeader.powerPlayPoints.localizedString:
            return sortOrder == .powerPlayPointsAscending ? .powerPlayPointsAscending : (sortOrder == .powerPlayPointsDescending ? .powerPlayPointsDescending : .none)
        case StatColumnHeader.wins.localizedString:
            return sortOrder == .winsAscending ? .winsAscending : (sortOrder == .winsDescending ? .winsDescending : .none)
        case StatColumnHeader.losses.localizedString:
            return sortOrder == .lossesAscending ? .lossesAscending : (sortOrder == .lossesDescending ? .lossesDescending : .none)
        case StatColumnHeader.otLosses.localizedString:
            return sortOrder == .otLossesAscending ? .otLossesAscending : (sortOrder == .otLossesDescending ? .otLossesDescending : .none)
        case StatColumnHeader.goalsAgainstPerGame.localizedString:
            return sortOrder == .goalsAgainstPerGameAscending ? .goalsAgainstPerGameAscending : (sortOrder == .goalsAgainstPerGameDescending ? .goalsAgainstPerGameDescending : .none)
        case StatColumnHeader.shutouts.localizedString:
            return sortOrder == .shutoutsAscending ? .shutoutsAscending : (sortOrder == .shutoutsDescending ? .shutoutsDescending : .none)
        default:
            return .none
        }
    }
}

