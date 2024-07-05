//
//  UsersData.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-07-04.
//

import Foundation

public struct UserData: Codable {
    public let userID: Int
    public let username: String
    public let favTeamID: Int?
}
