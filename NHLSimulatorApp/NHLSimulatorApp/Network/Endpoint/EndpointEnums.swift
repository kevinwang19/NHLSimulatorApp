//
//  EndpointEnums.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-07-04.
//

import Foundation

public enum NetworkEndpoint: EndpointInfo {
    case schedules
    case dateSchedules
    case teamSeasonSchedules
    case teamMonthSchedules
    case teams
    case players
    case teamPlayers
    case playerStats
    case playerSeasonStats
    case playerCareerStats
    case playerStatsPredictions
    case playerPredictedStats
    case lineups
    case playerLineups
    case teamLineups
    case users
    case simulations
    case simulate
    case finishSimulation
    case simulationPlayerStats
    case playerSimulatedStats
    case allPlayersSimulatedStats
    case simulationTeamStats
    case teamSimulatedStats
    case allTeamsSimulatedStats
    case simulationGameStats
    case gameSimulatedStats
    case allGamesSimulatedStats
    
    public var route: String {
        switch self {
        case .schedules:
            return "schedules"
        case .dateSchedules:
            return "schedules/date_schedules"
        case .teamSeasonSchedules:
            return "schedules/team_season_schedules"
        case .teamMonthSchedules:
            return "schedules/team_month_schedules"
        case .teams:
            return "teams"
        case .players:
            return "players"
        case .teamPlayers:
            return "players/team_players"
        case .playerStats:
            return "player_stats"
        case .playerSeasonStats:
            return "player_stats/player_season_stats"
        case .playerCareerStats:
            return "player_stats/player_career_stats"
        case .playerStatsPredictions:
            return "player_stats_predictions"
        case .playerPredictedStats:
            return "player_stats_predictions/player_predicted_stats"
        case .lineups:
            return "lineups"
        case .playerLineups:
            return "lineups/player_lineup"
        case .teamLineups:
            return "lineups/team_lineup"
        case .users:
            return "users"
        case .simulations:
            return "simulations"
        case .simulate:
            return "simulations/simulate_to_date"
        case .finishSimulation:
            return "simulations/finish"
        case .simulationPlayerStats:
            return "simulation_player_stats"
        case .playerSimulatedStats:
            return "simulation_player_stats/player_simulated_stats"
        case .allPlayersSimulatedStats:
            return "simulation_player_stats/simulation_stats"
        case .simulationTeamStats:
            return "simulation_team_stats"
        case .teamSimulatedStats:
            return "simulation_team_stats/team_simulated_stats"
        case .allTeamsSimulatedStats:
            return "simulation_team_stats/simulation_stats"
        case .simulationGameStats:
            return "simulation_game_stats"
        case .gameSimulatedStats:
            return "simulation_game_stats/game_simulated_stats"
        case .allGamesSimulatedStats:
            return "simulation_game_stats/simulation_stats"
        }
    }
}
