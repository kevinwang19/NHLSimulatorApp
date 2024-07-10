//
//  FetchCoreData.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-07-09.
//

import CoreData
import Foundation

extension CoreDataManager {
    func saveLineupCoreData(lineupData: LineupData) {
        for lineup in lineupData.lineups {
            guard let lineupEntity = NSEntityDescription.entity(forEntityName: "CoreLineup", in: context) else {
                return
            }
            guard let lineupManagedObject = NSManagedObject(entity: lineupEntity, insertInto: context) as? CoreLineup else {
                return
            }
            
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
    
    func fetchLineupsCoreData() -> [CoreLineup] {
        let fetchRequest: NSFetchRequest<CoreLineup> = CoreLineup.fetchRequest()
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch lineups: \(error)")
            return []
        }
    }
    
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
    
    func resetLineupsCoreData() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "CoreLineup")

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
