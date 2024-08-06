//
//  CorePlayerLineupService.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-08-05.
//

import CoreData
import Foundation

extension CoreDataManager {
    // Fetch player and lineup details from Core Data
    func fetchPlayersAndLineupsCoreData() -> [[String: Any]] {
        let players = fetchPlayersCoreData()
        let lineups = fetchLineupsCoreData()
        
        // Create a dictionary with playerID as the key for easy lookup
        var lineupsByPlayerID: [Int: CoreLineup] = [:]
        for lineup in lineups {
            lineupsByPlayerID[Int(lineup.playerID)] = lineup
        }
            
        // Map players and lineups to a dictionary representation
        let combinedResults: [[String: Any]] = players.compactMap { player in
            guard let lineup = lineupsByPlayerID[Int(player.playerID)] else {
                return nil
            }
                
            return [
                "lineupID": lineup.lineupID,
                "playerID": lineup.playerID,
                "teamID": lineup.teamID,
                "position": lineup.position ?? "",
                "lineNumber": lineup.lineNumber,
                "powerPlayLineNumber": lineup.powerPlayLineNumber,
                "penaltyKillLineNumber": lineup.penaltyKillLineNumber,
                "otLineNumber": lineup.otLineNumber,
                "offensiveRating": player.offensiveRating,
                "defensiveRating": player.defensiveRating
            ]
        }
        
        return combinedResults
    }
}
