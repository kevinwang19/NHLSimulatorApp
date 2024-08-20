//
//  SimulationPlayoffSkaterStatsData.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-08-14.
//

import Foundation

public struct SimulationPlayoffSkaterStatsData: Codable {
    public let playoffSkaterStats: [SimulationPlayoffSkaterStat]
}

public struct SimulationPlayoffSkaterStat: Codable, Hashable {
    public let playerID: Int
    public let fullName: String
    public let gamesPlayed: Int
    public let goals: Int
    public let assists: Int
    public let points: Int
    public let powerPlayGoals: Int
    public let powerPlayPoints: Int
}
