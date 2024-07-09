//
//  SimulationTeamStatsData.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-07-09.
//

import Foundation

public struct SimulationTeamStatsData: Codable {
    public let teamStats: [SimulationTeamStat]
}

public struct SimulationTeamStat: Codable {
    public let gamesPlayed: Int
    public let wins: Int
    public let losses: Int
    public let otLosses: Int
    public let points: Int
    public let goalsFor: Int
    public let goalsForPerGame: Decimal
    public let goalsAgainst: Int
    public let goalsAgainstPerGame: Decimal
    public let totalPowerPlays: Int
    public let powerPlayPctg: Decimal
    public let totalPenaltyKills: Int
    public let penaltyKillPctg: Decimal
    public let divisionRank: Int
    public let conferenceRank: Int
    public let leagueRank: Int
    public let isWildCard: Bool
    public let isPresidents: Bool
}
