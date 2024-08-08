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
            .frame(width: title == NSLocalizedString(StatColumnHeader.name.rawValue, comment: "") ? nameColumnWidth : statColumnWidth, alignment: title == NSLocalizedString(StatColumnHeader.name.rawValue, comment: "") ? .leading : .center)
        }
    }
    
    // Determine whether the clicking the header will sort the stat in ascending or descending order
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
    
    // Determine whether the current stat is ascending or descending
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

