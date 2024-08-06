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
    case skaterSeasonStats
    case skaterCareerStats
    case goalieSeasonStats
    case goalieCareerStats
    case skaterStatsPredictions
    case goalieStatsPredictions
    case lineups
    case users
    case simulations
    case simulate
    case finishSimulation
    case userRecentSimulation
    case simulationIndividualSkaterStats
    case simulationTeamSkaterStats
    case simulationTeamPositionSkaterStats
    case simulationIndividualGoalieStats
    case simulationTeamGoalieStats
    case simulationTeamStats
    case teamSimulatedStats
    case allTeamsSimulatedStats
    case teamSimulatedGameStats
    
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
        case .simulationIndividualSkaterStats:
            return "simulation_skater_stats/simulation_individual_stat"
        case .simulationTeamSkaterStats:
            return "simulation_skater_stats/simulation_team_stats"
        case .simulationTeamPositionSkaterStats:
            return "simulation_skater_stats/simulation_team_position_stats"
        case .simulationIndividualGoalieStats:
            return "simulation_goalie_stats/simulation_individual_stat"
        case .simulationTeamGoalieStats:
            return "simulation_goalie_stats/simulation_team_stats"
        case .simulationTeamStats:
            return "simulation_team_stats"
        case .teamSimulatedStats:
            return "simulation_team_stats/team_simulated_stats"
        case .allTeamsSimulatedStats:
            return "simulation_team_stats/simulation_stats"
        case .teamSimulatedGameStats:
            return "simulation_game_stats/team_simulated_game_stats"
        }
    }
}
