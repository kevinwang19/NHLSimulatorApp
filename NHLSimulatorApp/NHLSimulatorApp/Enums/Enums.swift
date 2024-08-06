//
//  Enums.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-07-15.
//

import Foundation
import SwiftUI

enum AppInfo: String {
    case appModel = "NHLSimulatorAppModel"
    case corePlayer = "CorePlayer"
    case coreLineup = "CoreLineup"
}

enum UserDefaultName: String {
    case isFirstLaunch
    case userID
    case favTeamIndex
    case simulationID
    case season
}

enum ElementLabel: String {
    case teams = "Teams"
    case scroll = "Scroll"
    case previous = "Previous"
    case next = "Next"
    case playerType = "Player Type"
}

enum Symbols: String {
    case atSymbol = "@"
    case dashSymbol = "-"
    case colonSymbol = ":"
    case win = "W"
    case loss = "L"
    case versus = "vs"
    case calendarPlaceholder = "00"
    case leftArrow = "chevron.left"
    case rightArrow = "chevron.right"
}

enum SortOrder {
    case none
    case nameAscending
    case nameDescending
    case gamesPlayedAscending
    case gamesPlayedDescending
    case goalsAscending
    case goalsDescending
    case assistsAscending
    case assistsDescending
    case pointsAscending
    case pointsDescending
    case powerPlayGoalsAscending
    case powerPlayGoalsDescending
    case powerPlayPointsAscending
    case powerPlayPointsDescending
    case winsAscending
    case winsDescending
    case lossesAscending
    case lossesDescending
    case otLossesAscending
    case otLossesDescending
    case goalsAgainstPerGameAscending
    case goalsAgainstPerGameDescending
    case shutoutsAscending
    case shutoutsDescending
}

enum StatColumnHeader: String {
    case name
    case gamesPlayed = "games_played"
    case goals
    case assists
    case points
    case powerPlayGoals = "powerplay_goals"
    case powerPlayPoints = "powerplay_points"
    case wins
    case losses
    case otLosses = "ot_losses"
    case goalsAgainstPerGame = "goals_against_per_game"
    case shutouts
}

enum LocalizedText: String {
    case nhlSimulator = "nhl_simulator"
    case newSim = "new_sim"
    case lastSim = "last_sim"
    case username
    case favoriteTeam = "favorite_team"
    case start
    case usernameCharacterError = "username_character_error"
    case usernameLengthError = "username_length_error"
    case usernameEmptyError = "username_empty_error"
    case simulationSetupMessage = "simulation_setup_message"
    case simulateTo = "simulate_to"
    case simulating
    case teamStandings = "team_standings"
    case playerStats = "player_stats"
    case editRosters = "edit_rosters"
    case editLineups = "edit_lineups"
    case back = "back"
}
