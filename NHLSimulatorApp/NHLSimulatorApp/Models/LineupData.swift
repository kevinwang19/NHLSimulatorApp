//
//  LineupData.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-07-05.
//

import Foundation

public struct LineupData: Codable {
    public let lineups: [Lineup]
}

public struct Lineup: Codable {
    public let playerID: Int
    public let teamID: Int?
    public let position: String
    public let lineNumber: Int?
    public let powerPlayLineNumber: Int?
    public let penaltyKillLineNumber: Int?
    public let otLineNumber: Int?
}
