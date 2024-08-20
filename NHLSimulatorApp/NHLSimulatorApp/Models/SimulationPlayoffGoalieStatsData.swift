//
//  SimulationPlayoffGoalieStatsData.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-08-14.
//

import Foundation

public struct SimulationPlayoffGoalieStatsData: Codable {
    public let playoffGoalieStats: [SimulationPlayoffGoalieStat]
}

public struct SimulationPlayoffGoalieStat: Codable, Hashable {
    public let playerID: Int
    public let fullName: String
    public let gamesPlayed: Int
    public let wins: Int
    public let losses: Int
    public let otLosses: Int
    public let goalsAgainstPerGame: Float
    public let shutouts: Int
}
