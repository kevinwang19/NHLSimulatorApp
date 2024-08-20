//
//  FetchCoreData.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-07-09.
//

import CoreData
import Foundation

extension CoreDataManager {
    // Save lineup data to Core Data
    func saveLineupCoreData(lineupData: [Lineup]) {
        for lineup in lineupData {
            // Create entity description for CoreLineup entity
            guard let lineupEntity = NSEntityDescription.entity(forEntityName: AppInfo.coreLineup.rawValue, in: context) else {
                return
            }
            
            // Create managed object for CoreLineup
            guard let lineupManagedObject = NSManagedObject(entity: lineupEntity, insertInto: context) as? CoreLineup else {
                return
            }
            
            // Assign lineup data to the managed object
            lineupManagedObject.lineupID = Int64(lineup.lineupID)
            lineupManagedObject.playerID = Int64(lineup.playerID)
            lineupManagedObject.teamID = Int64(lineup.teamID)
            lineupManagedObject.position = lineup.position
            if let lineNumber = lineup.lineNumber {
                lineupManagedObject.lineNumber = Int16(lineNumber)
            }
            if let powerPlayLineNumber = lineup.powerPlayLineNumber {
                lineupManagedObject.powerPlayLineNumber = Int16(powerPlayLineNumber)
            }
            if let penaltyKillLineNumber = lineup.penaltyKillLineNumber {
                lineupManagedObject.penaltyKillLineNumber = Int16(penaltyKillLineNumber)
            }
            if let otLineNumber = lineup.otLineNumber {
                lineupManagedObject.otLineNumber = Int16(otLineNumber)
            }
        }
        
        saveContext()
    }
    
    // Fetch all lineups from Core Data
    func fetchLineupsCoreData() -> [CoreLineup] {
        let fetchRequest: NSFetchRequest<CoreLineup> = CoreLineup.fetchRequest()
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch lineups: \(error)")
            return []
        }
    }
    
    // Fetch a player's lineup details from Core Data
    func fetchPlayerLineupCoreData(playerID: Int) -> CoreLineup? {
        let fetchRequest: NSFetchRequest<CoreLineup> = CoreLineup.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "playerID == %d", playerID)
        do {
            let lineups = try context.fetch(fetchRequest)
            return lineups.first
        } catch {
            print("Failed to fetch player lineup: \(error)")
            return nil
        }
    }
    
    // Fetch certain player lineup details from Core Data
    func fetchCertainPlayerLineupCoreData(playerIDs: [Int64]) -> [CoreLineup] {
        let fetchRequest: NSFetchRequest<CoreLineup> = CoreLineup.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "playerID IN %@", playerIDs)
        do {
            let lineups = try context.fetch(fetchRequest)
            return lineups
        } catch {
            print("Failed to fetch lineups: \(error)")
            return []
        }
    }
    
    // Fetch all lineups belonging to a specific team from Core Data
    func fetchTeamLineupsCoreData(teamID: Int) -> [CoreLineup] {
        let fetchRequest: NSFetchRequest<CoreLineup> = CoreLineup.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "teamID == %d", teamID)
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch team lineups: \(error)")
            return []
        }
    }
    
    // Fetch all lineups belonging to a specific team from Core Data
    func fetchTeamPositionLineupsCoreData(teamID: Int, positions: [String]) -> [CoreLineup] {
        let fetchRequest: NSFetchRequest<CoreLineup> = CoreLineup.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "teamID == %d AND position IN %@", teamID, positions)
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch team position lineups: \(error)")
            return []
        }
    }
    
    // Update lineup properties from Core Data
    func updateLineupsCoreData(playerID: Int, teamID: Int64, position: String, lineNumber: Int16, powerPlayLineNumber: Int16, penaltyKillLineNumber: Int16, otLineNumber: Int16) {
        let fetchRequest: NSFetchRequest<CoreLineup> = CoreLineup.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "playerID == %d", playerID)
        do {
            let lineups = try context.fetch(fetchRequest)
            
            for lineup in lineups {
                lineup.teamID = teamID
                lineup.position = position
                lineup.lineNumber = lineNumber
                lineup.powerPlayLineNumber = powerPlayLineNumber
                lineup.penaltyKillLineNumber = penaltyKillLineNumber
                lineup.otLineNumber = otLineNumber
            }
            
            saveContext()
        } catch {
            print("Failed to update lineups: \(error)")
        }
    }
    
    // Reset all lineups in Core Data
    func resetLineupsCoreData() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: AppInfo.coreLineup.rawValue)

        do {
            let entities = try context.fetch(fetchRequest)
            for case let entity as NSManagedObject in entities {
                context.delete(entity)
            }
            
            saveContext()
        } catch {
            print("Failed to reset lineups: \(error)")
        }
    }
}
