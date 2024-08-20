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
    case isPlayoffs
    case playoffRound1Complete
    case playoffRound2Complete
    case playoffRound3Complete
    case seasonComplete
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
    case dot = " • "
    case number = "#"
    case feet = "'"
    case inch = "\""
    case pounds = "lbs"
    case win = "W"
    case loss = "L"
    case versus = "vs"
    case wildcard = "( W )"
    case presidents = "( P )"
    case calendarPlaceholder = "00"
    case leftArrow = "chevron.left"
    case rightArrow = "chevron.right"
    case leftRightArrow = "arrow.left.and.right"
}

enum SortOrder {
    case none
    case rankAscending
    case rankDescending
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
    case shutoutsAscending
    case shutoutsDescending
    case goalsForAscending
    case goalsForDescending
    case goalsForPerGameAscending
    case goalsForPerGameDescending
    case goalsAgainstAscending
    case goalsAgainstDescending
    case goalsAgainstPerGameAscending
    case goalsAgainstPerGameDescending
    case powerplayPctgAscending
    case powerplayPctgDescending
    case penaltyKillPctgAscending
    case penaltyKillPctgDescending
}

enum StatColumnHeader: String {
    case top50 = "top_50"
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
    case shutouts
    case goalsFor = "goals_for"
    case goalsForPerGame = "goals_for_per_game"
    case goalsAgainst = "goals_against"
    case goalsAgainstPerGame = "goals_against_per_game"
    case powerplayPctg = "powerplay_pctg"
    case penaltyKillPctg = "penalty_kill_pctg"
    case rank = "rank"
    case season
    case avgToi = "avg_toi"
    case faceoffWinningPctg = "faceoff_winning_pctg"
    case gameWinningGoals = "game_winning_goals"
    case otGoals = "ot_goals"
    case pim
    case plusMinus = "plus_minus"
    case shootingPctg = "shooting_pctg"
    case shorthandedGoals = "shorthanded_goals"
    case shorthandedPoints = "shorthanded_points"
    case shots
    case gamesStarted = "games_started"
    case goalsAgainstAvg = "goals_against_avg"
    case savePctg = "save_pctg"
    case shotsAgainst = "shots_against"
    
    var localizedString: String {
        NSLocalizedString(self.rawValue, comment: "")
    }
}

enum PlayerType: String, CaseIterable, Identifiable {
    case skaters
    case goalies
    
    var id: String { self.rawValue }
    
    var localizedStringKey: LocalizedStringKey {
        LocalizedStringKey(self.rawValue)
    }
}

enum PositionType: String, CaseIterable, Identifiable {
    case all
    case forwards = "F"
    case centers = "C"
    case leftForwards = "L"
    case leftWingers = "LW"
    case rightForwards = "R"
    case rightWingers = "RW"
    case defensemen = "D"
    case leftDefensemen = "LD"
    case rightDefensemen = "RD"
    case goalies = "G"
    
    var id: String { self.rawValue }
    
    var localizedString: String {
        NSLocalizedString(self.rawValue, comment: "")
    }
}

enum RankType: String {
    case league
    case conference
    case division
}

enum ConferenceType: String, CaseIterable, Identifiable {
    case all
    case eastern
    case western
    
    var id: String { self.rawValue }
    
    var localizedStringKey: LocalizedStringKey {
        LocalizedStringKey(self.rawValue)
    }
}

enum EastDivisionType: String, CaseIterable, Identifiable {
    case all
    case atlantic
    case metropolitan
    
    var id: String { self.rawValue }
    
    var localizedStringKey: LocalizedStringKey {
        LocalizedStringKey(self.rawValue)
    }
}

enum WestDivisionType: String, CaseIterable, Identifiable {
    case all
    case central
    case pacific
    
    var id: String { self.rawValue }
    
    var localizedStringKey: LocalizedStringKey {
        LocalizedStringKey(self.rawValue)
    }
}

enum LineupType: String, CaseIterable, Identifiable {
    case evenStrength = "ES"
    case powerplay = "PP"
    case penaltyKill = "PK"
    case overtime = "OT"
    
    var id: String { self.rawValue }
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
    case back
    case noStats = "no_stats"
    case standingsLegend = "standings_legend"
    case careerStats = "career_stats"
    case predictedStats = "predicted_stats"
    case noPlayerDetails = "no_player_details"
    case born
    case height
    case weight
    case line
    case selectPlayerSwap = "select_player_swap"
    case swap
    case selectTeamChange = "select_team_change"
    case clearSelections = "clear_selections"
    case performSwitch = "perform_switch"
    case creatingPlayoffs = "creating_playoffs"
    
    var localizedString: String {
        NSLocalizedString(self.rawValue, comment: "")
    }
}
