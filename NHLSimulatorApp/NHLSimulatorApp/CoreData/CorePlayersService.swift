//
//  CreateCoreData.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-07-09.
//

import CoreData
import Foundation

extension CoreDataManager {
    func savePlayersCoreData(playerData: PlayerData) {
        for player in playerData.players {
            guard let playerEntity = NSEntityDescription.entity(forEntityName: "CorePlayer", in: context) else {
                return
            }
            guard let playerManagedObject = NSManagedObject(entity: playerEntity, insertInto: context) as? CorePlayer else {
                return
            }
            
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
            playerManagedObject.teamID = Int64(player.teamID)
            playerManagedObject.offensiveRating = Int16(player.offensiveRating)
            playerManagedObject.defensiveRating = Int16(player.defensiveRating)
        }
    }
    
    func fetchPlayersCoreData() -> [CorePlayer] {
        let fetchRequest: NSFetchRequest<CorePlayer> = CorePlayer.fetchRequest()
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch players: \(error)")
            return []
        }
    }
    
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
    
    func resetPlayersCoreData() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "CorePlayer")

        do {
            let entities = try context.fetch(fetchRequest)
            for case let entity as NSManagedObject in entities {
                context.delete(entity)
            }
            try context.save()
        } catch {
            print("Failed to reset players: \(error)")
        }
    }
}
