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
    func saveLineupCoreData(lineupData: LineupData) {
        for lineup in lineupData.lineups {
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
            lineupManagedObject.teamID = Int64(lineup.teamID)
            lineupManagedObject.position = lineup.position
            if let lineNumber = lineup.lineNumber {
                lineupManagedObject.lineNumber = Int16(lineNumber)
            }
            if let powerPlayLineNumber = lineup.powerPlayLineNumber {
                lineupManagedObject.lineNumber = Int16(powerPlayLineNumber)
            }
            if let penaltyKillLineNumber = lineup.penaltyKillLineNumber {
                lineupManagedObject.lineNumber = Int16(penaltyKillLineNumber)
            }
            if let otLineNumber = lineup.otLineNumber {
                lineupManagedObject.lineNumber = Int16(otLineNumber)
            }
            
            if let player = fetchPlayerCoreData(playerID: lineup.playerID) {
                lineupManagedObject.belongsToPlayer = player
            }
        }
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
    
    // Reset all lineups in Core Data
    func resetLineupsCoreData() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: AppInfo.coreLineup.rawValue)

        do {
            let entities = try context.fetch(fetchRequest)
            for case let entity as NSManagedObject in entities {
                context.delete(entity)
            }
            try context.save()
        } catch {
            print("Failed to reset lineups: \(error)")
        }
    }
}
