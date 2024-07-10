//
//  PlayerData.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-07-04.
//

import Foundation

public struct PlayerData: Codable {
    public let players: [Player]
}

public struct Player: Codable {
    public let playerID: Int
    public let headshot: String?
    public let firstName: String
    public let lastName: String
    public let sweaterNumber: Int?
    public let positionCode: String
    public let shootsCatches: String
    public let heightInInches: Int
    public let weightInPounds: Int
    public let birthDate: String
    public let birthCountry: String
    public let teamID: Int
    public let offensiveRating: Int
    public let defensiveRating: Int
}
