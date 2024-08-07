//
//  TeamData.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-07-04.
//

import Foundation

public struct TeamData: Codable {
    public let teams: [Team]
}

public struct Team: Codable {
    public var teamID: Int
    public let fullName: String
    public let abbrev: String
    public let logo: String
    public let conference: String
    public let division: String
}
