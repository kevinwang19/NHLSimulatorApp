//
//  SimulationGameStatsData.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-07-09.
//

import Foundation

public struct SimulationGameStatsData: Codable {
    public let gameStats: [SimulationGameStat]
}

public struct SimulationGameStat: Codable {
    public let awayTeamID: Int
    public let awayTeamScore: Int
    public let homeTeamID: Int
    public let homeTeamScore: Int
}
