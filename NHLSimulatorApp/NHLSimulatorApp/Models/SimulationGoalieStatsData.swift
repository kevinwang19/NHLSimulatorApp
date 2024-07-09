//
//  SimulationGoalieStatsData.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-07-05.
//

import Foundation

public struct SimulationGoalieStatsData: Codable {
    public let goalieStats: [SimulationGoalieStat]
}

public struct SimulationGoalieStat: Codable {
    public let gamesPlayed: Int
    public let wins: Int
    public let losses: Int
    public let otLosses: Int
    public let goalsAgainstPerGame: Decimal
    public let shutouts: Int
}
