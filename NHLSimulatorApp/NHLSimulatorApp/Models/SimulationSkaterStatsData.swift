//
//  SimulationSkaterStatsData.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-07-05.
//

import Foundation

public struct SimulationSkaterStatsData: Codable {
    public let skaterStats: [SimulationSkaterStat]
}

public struct SimulationSkaterStat: Codable, Hashable {
    public let fullName: String
    public let gamesPlayed: Int
    public let goals: Int
    public let assists: Int
    public let points: Int
    public let powerPlayGoals: Int
    public let powerPlayPoints: Int
}
