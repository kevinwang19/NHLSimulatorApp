//
//  ScheduleData.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-07-04.
//

import Foundation

public struct ScheduleData: Codable {
    public let schedules: [Schedule]
}

public struct Schedule: Codable {
    public let scheduleID: Int
    public let date: String
    public let dayAbbrev: String
    public let season: Int
    public let awayTeamID: Int
    public let awayTeamAbbrev: String
    public let awayTeamLogo: String
    public let homeTeamID: Int
    public let homeTeamAbbrev: String
    public let homeTeamLogo: String
}
