//
//  GoalieStatsData.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-07-04.
//

import Foundation

public struct GoalieStatsData: Codable {
    public let goalieStats: [GoalieStat]
}

public struct GoalieStat: Codable {
    public let season: Int?
    public let gamesPlayed: Int
    public let gamesStarted: Int
    public let wins: Int
    public let losses: Int
    public let otLosses: Int
    public let goalsAgainst: Int
    public let goalsAgainstAvg: Decimal
    public let savePctg: Decimal
    public let shotsAgainst: Int
    public let shutouts: Int
}

