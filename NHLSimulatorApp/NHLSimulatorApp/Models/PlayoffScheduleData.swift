//
//  PlayoffScheduleData.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-08-14.
//

import Foundation

public struct PlayoffScheduleData: Codable {
    public let playoffSchedules: [PlayoffSchedule]
}

public struct PlayoffSchedule: Codable {
    public let simulationID: Int
    public let date: String
    public let awayTeamID: Int
    public let awayTeamAbbrev: String
    public let awayTeamLogo: String
    public let awayTeamScore: Int?
    public let homeTeamID: Int
    public let homeTeamAbbrev: String
    public let homeTeamLogo: String
    public let homeTeamScore: Int?
    public let roundNumber: Int
    public let conference: String
    public let matchupNumber: Int
}
