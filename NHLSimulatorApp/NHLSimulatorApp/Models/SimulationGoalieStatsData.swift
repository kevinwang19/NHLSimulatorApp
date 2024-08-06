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

public struct SimulationGoalieStat: Codable, Hashable {
    public let fullName: String
    public let gamesPlayed: Int
    public let wins: Int
    public let losses: Int
    public let otLosses: Int
    public let goalsAgainstPerGame: Float
    public let shutouts: Int
}
