//
//  PlayerStatsData.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-07-04.
//

import Foundation

public struct SkaterStatsData: Codable {
    public let skaterStats: [SkaterStat]
}

public struct SkaterStat: Codable {
    public let season: Int?
    public let gamesPlayed: Int
    public let goals: Int
    public let assists: Int
    public let points: Int
    public let faceoffWinningPctg: Decimal
    public let gameWinningGoals: Int
    public let pim: Int
    public let plusMinus: Int
    public let powerPlayGoals: Int
    public let powerPlayPoints: Int
    public let shootingPctg: Decimal
    public let shorthandedGoals: Int
    public let shorthandedPoints: Int
    public let shots: Int
}
