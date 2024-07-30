//
//  EndpointEnums.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-07-04.
//

import Foundation

public enum NetworkEndpoint: EndpointInfo {
    case teamDaySchedule
    case teamMonthSchedules
    case teams
    case players
    case teamPlayers
    case skaterSeasonStats
    case skaterCareerStats
    case goalieSeasonStats
    case goalieCareerStats
    case skaterStatsPredictions
    case goalieStatsPredictions
    case lineups
    case playerLineups
    case teamLineups
    case users
    case simulations
    case simulate
    case finishSimulation
    case userRecentSimulation
    case simulationSkaterStats
    case simulationAllSkaterStats
    case simulationGoalieStats
    case simulationAllGoalieStats
    case simulationTeamStats
    case teamSimulatedStats
    case allTeamsSimulatedStats
    case simulationGameStats
    case gameSimulatedStats
    case allGamesSimulatedStats
    
    public var route: String {
        switch self {
        case .teamDaySchedule:
            return "schedules/team_date_schedule"
        case .teamMonthSchedules:
            return "schedules/team_month_schedules"
        case .teams:
            return "teams"
        case .players:
            return "players"
        case .teamPlayers:
            return "players/team_players"
        case .skaterSeasonStats:
            return "skater_stats/skater_season_stats"
        case .skaterCareerStats:
            return "skater_stats/skater_career_stats"
        case .goalieSeasonStats:
            return "goalie_stats/goalie_season_stats"
        case .goalieCareerStats:
            return "goalie_stats/goalie_career_stats"
        case .skaterStatsPredictions:
            return "skater_stats_predictions"
        case .goalieStatsPredictions:
            return "goalie_stats_predictions"
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
        case .userRecentSimulation:
            return "simulations/user_simulation"
        case .simulationSkaterStats:
            return "simulation_skater_stats"
        case .simulationAllSkaterStats:
            return "simulation_skater_stats/simulation_stats"
        case .simulationGoalieStats:
            return "simulation_goalie_stats"
        case .simulationAllGoalieStats:
            return "simulation_goalie_stats/simulation_stats"
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
