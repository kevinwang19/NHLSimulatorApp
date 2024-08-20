//
//  SimulationPlayoffTeamStatsData.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-08-14.
//

import Foundation

public struct SimulationPlayoffTeamStatsData: Codable {
    public let playoffTeamStats: [SimulationPlayoffTeamStat]
}

public struct SimulationPlayoffTeamStat: Codable, Hashable {
    public let simulationID: Int
    public let teamID: Int
    public let fullName: String
    public let gamesPlayed: Int
    public let wins: Int
    public let losses: Int
    public let otLosses: Int
    public let goalsFor: Int
    public let goalsForPerGame: Float
    public let goalsAgainst: Int
    public let goalsAgainstPerGame: Float
    public let totalPowerPlays: Int
    public let powerPlayPctg: Float
    public let totalPenaltyKills: Int
    public let penaltyKillPctg: Float
}
