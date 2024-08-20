//
//  CreateCoreData.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-07-09.
//

import CoreData
import Foundation

extension CoreDataManager {
    // Save player data to Core Data
    func savePlayersCoreData(playerData: [Player]) {
        for player in playerData {
            // Create entity description for CorePlayer entity
            guard let playerEntity = NSEntityDescription.entity(forEntityName: AppInfo.corePlayer.rawValue, in: context) else {
                return
            }
            
            // Create managed object for CorePlayer
            guard let playerManagedObject = NSManagedObject(entity: playerEntity, insertInto: context) as? CorePlayer else {
                return
            }
            
            // Assign player data to the managed object
            playerManagedObject.playerID = Int64(player.playerID)
            playerManagedObject.headshot = player.headshot
            playerManagedObject.firstName = player.firstName
            playerManagedObject.lastName = player.lastName
            if let sweaterNumber = player.sweaterNumber {
                playerManagedObject.sweaterNumber = Int16(sweaterNumber)
            }
            playerManagedObject.positionCode = player.positionCode
            playerManagedObject.shootsCatches = player.shootsCatches
            playerManagedObject.heightInInches = Int16(player.heightInInches)
            playerManagedObject.weightInPounds = Int16(player.weightInPounds)
            if let birthDate = player.birthDate {
                playerManagedObject.birthDate = birthDate
            }
            if let birthCountry = player.birthCountry {
                playerManagedObject.birthCountry = birthCountry
            }
            playerManagedObject.teamID = Int64(player.teamID)
            playerManagedObject.offensiveRating = Int16(player.offensiveRating ?? 0)
            playerManagedObject.defensiveRating = Int16(player.defensiveRating ?? 0)
        }
        
        saveContext()
    }
    
    // Fetch all players from Core Data
    func fetchPlayersCoreData() -> [CorePlayer] {
        let fetchRequest: NSFetchRequest<CorePlayer> = CorePlayer.fetchRequest()
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch players: \(error)")
            return []
        }
    }
    
    // Fetch a player by playerID from Core Data
    func fetchPlayerCoreData(playerID: Int) -> CorePlayer? {
        let fetchRequest: NSFetchRequest<CorePlayer> = CorePlayer.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "playerID == %d", playerID)
        do {
            let players = try context.fetch(fetchRequest)
            return players.first
        } catch {
            print("Failed to fetch player: \(error)")
            return nil
        }
    }
    
    // Fetch certain players by playerIDs from Core Data
    func fetchCertainPlayersCoreData(playerIDs: [Int64]) -> [CorePlayer] {
        let fetchRequest: NSFetchRequest<CorePlayer> = CorePlayer.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "playerID IN %@", playerIDs)
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch players: \(error)")
            return []
        }
    }
    
    // Fetch all players belonging to a specific team from Core Data
    func fetchTeamPlayersCoreData(teamID: Int) -> [CorePlayer] {
        let fetchRequest: NSFetchRequest<CorePlayer> = CorePlayer.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "teamID == %d", teamID)
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch team players: \(error)")
            return []
        }
    }
    
    // Update player properties from Core Data
    func updatePlayerCoreData(playerID: Int64, teamID: Int) {
        let fetchRequest: NSFetchRequest<CorePlayer> = CorePlayer.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "playerID == %d", playerID)
        do {
            let players = try context.fetch(fetchRequest)
            
            for player in players {
                player.teamID = Int64(teamID)
            }
            
            saveContext()
        } catch {
            print("Failed to update player: \(error)")
        }
    }
    
    // Reset all players in Core Data
    func resetPlayersCoreData() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: AppInfo.corePlayer.rawValue)

        do {
            let entities = try context.fetch(fetchRequest)
            for case let entity as NSManagedObject in entities {
                context.delete(entity)
            }
            
            saveContext()
        } catch {
            print("Failed to reset players: \(error)")
        }
    }
}
