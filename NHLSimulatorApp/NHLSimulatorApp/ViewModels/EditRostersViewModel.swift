//
//  EditRostersViewModel.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-08-05.
//

import Foundation
import RxSwift
import SwiftUI

class EditRostersViewModel: ObservableObject {
    @Published var teams: [Team] = []
    @Published var otherTeams: [Team] = []
    @Published var players: [CorePlayer] = []
    @Published var otherPlayers: [CorePlayer] = []
    @Published var switchMessage: String = ""
    private let disposeBag = DisposeBag()
    
    // Fetch all teams
    func fetchTeams(selectedTeamIndex: Int, completion: @escaping (Bool) -> Void) {
        NetworkManager.shared.getAllTeams().subscribe(onSuccess: { [weak self] teamData in
            guard let self = self else {
                completion(false)
                return
            }
                
            self.teams = teamData.teams
            self.otherTeams = teamData.teams
            self.otherTeams.remove(at: selectedTeamIndex)
            completion(true)
        }, onFailure: { error in
            print("Failed to fetch teams: \(error)")
            completion(false)
        })
        .disposed(by: disposeBag)
    }
    
    // Fetch all players from a team
    func fetchTeamPlayers(teamID: Int, selectedTeamID: Int, completion: @escaping (Bool) -> Void) {
        if teamID == selectedTeamID {
            // Only use players that exist in lineups data and sort by last name
            let lineupPlayerIDs = CoreDataManager.shared.fetchTeamLineupsCoreData(teamID: teamID).map { $0.playerID }
                
            players = CoreDataManager.shared.fetchTeamPlayersCoreData(teamID: teamID)
                .filter { lineupPlayerIDs.contains($0.playerID) }
                .sorted { $0.lastName ?? "" < $1.lastName ?? "" }
            
            completion(true)
        } else {
            // Only use players that exist in lineups data and sort by last name
            let lineupPlayerIDs = CoreDataManager.shared.fetchTeamLineupsCoreData(teamID: teamID).map { $0.playerID }
                
            otherPlayers = CoreDataManager.shared.fetchTeamPlayersCoreData(teamID: teamID)
                .filter { lineupPlayerIDs.contains($0.playerID) }
                .sorted { $0.lastName ?? "" < $1.lastName ?? "" }
            
            completion(true)
        }
    }
    
    // Update rosters for selected players on two teams
    func updateRosters(teamID: Int, playerIDs: [Int64], otherTeamID: Int, otherPlayerIDs: [Int64], completion: @escaping (Bool) -> Void) {
        let minSkaters = 18
        let minGoalies = 2
        
        // Early exit if no players selected
        guard !playerIDs.isEmpty || !otherPlayerIDs.isEmpty else {
            switchMessage = "ERROR: NO PLAYERS SELECTED"
            completion(true)
            return
        }
        
        // Fetch and filter data
        let teamLineups = CoreDataManager.shared.fetchTeamLineupsCoreData(teamID: teamID)
        let otherTeamLineups = CoreDataManager.shared.fetchTeamLineupsCoreData(teamID: otherTeamID)
        
        let skaterLineups = teamLineups.filter { $0.position != PositionType.goalies.rawValue }
        let forwardLineups = teamLineups.filter {
            $0.position == PositionType.centers.rawValue ||
            $0.position == PositionType.leftWingers.rawValue ||
            $0.position == PositionType.rightWingers.rawValue
        }
        let defenseLineups = teamLineups.filter {
            $0.position == PositionType.leftDefensemen.rawValue ||
            $0.position == PositionType.rightDefensemen.rawValue
        }
        let goalieLineups = teamLineups.filter { $0.position == PositionType.goalies.rawValue }
        
        let otherSkaterLineups = otherTeamLineups.filter { $0.position != PositionType.goalies.rawValue }
        let otherForwardLineups = otherTeamLineups.filter {
            $0.position == PositionType.centers.rawValue ||
            $0.position == PositionType.leftWingers.rawValue ||
            $0.position == PositionType.rightWingers.rawValue
        }
        let otherDefenseLineups = otherTeamLineups.filter {
            $0.position == PositionType.leftDefensemen.rawValue ||
            $0.position == PositionType.rightDefensemen.rawValue
        }
        let otherGoalieLineups = otherTeamLineups.filter { $0.position == PositionType.goalies.rawValue }
        
        let playerLineups = CoreDataManager.shared.fetchCertainPlayerLineupCoreData(playerIDs: playerIDs)
        let otherPlayerLineups = CoreDataManager.shared.fetchCertainPlayerLineupCoreData(playerIDs: otherPlayerIDs)
        
        let sortedForwardLineups = playerLineups.filter {
            $0.position == PositionType.centers.rawValue ||
            $0.position == PositionType.leftWingers.rawValue ||
            $0.position == PositionType.rightWingers.rawValue
        }.sorted { $0.lineNumber > $1.lineNumber }
        let sortedDefenseLineups = playerLineups.filter {
            $0.position == PositionType.leftDefensemen.rawValue ||
            $0.position == PositionType.rightDefensemen.rawValue
        }.sorted { $0.lineNumber > $1.lineNumber }
        let sortedGoalieLineups = playerLineups.filter {
            $0.position == PositionType.goalies.rawValue
        }.sorted { $0.lineNumber > $1.lineNumber }
        
        let sortedOtherForwardLineups = otherPlayerLineups.filter {
            $0.position == PositionType.centers.rawValue ||
            $0.position == PositionType.leftWingers.rawValue ||
            $0.position == PositionType.rightWingers.rawValue
        }.sorted { $0.lineNumber > $1.lineNumber }
        let sortedOtherDefenseLineups = otherPlayerLineups.filter {
            $0.position == PositionType.leftDefensemen.rawValue ||
            $0.position == PositionType.rightDefensemen.rawValue
        }.sorted { $0.lineNumber > $1.lineNumber }
        let sortedOtherGoalieLineups = otherPlayerLineups.filter {
            $0.position == PositionType.goalies.rawValue
        }.sorted { $0.lineNumber > $1.lineNumber }
        
        // Validation checks
        guard skaterLineups.count - (sortedForwardLineups.count + sortedDefenseLineups.count) + (sortedOtherForwardLineups.count + sortedOtherDefenseLineups.count) >= minSkaters else {
            switchMessage = "ERROR: TEAM 1 WOULD HAVE LESS THAN 18 SKATERS"
            completion(true)
            return
        }
        
        guard goalieLineups.count - sortedGoalieLineups.count + sortedOtherGoalieLineups.count >= minGoalies else {
            switchMessage = "ERROR: TEAM 1 WOULD HAVE LESS THAN 2 GOALIES"
            completion(true)
            return
        }
        
        guard otherSkaterLineups.count - (sortedOtherForwardLineups.count + sortedOtherDefenseLineups.count) + (sortedForwardLineups.count + sortedDefenseLineups.count) >= minSkaters else {
            switchMessage = "ERROR: TEAM 2 WOULD HAVE LESS THAN 18 SKATERS"
            completion(true)
            return
        }
        
        guard otherGoalieLineups.count - sortedOtherGoalieLineups.count + sortedGoalieLineups.count >= minGoalies else {
            switchMessage = "ERROR: TEAM 2 WOULD HAVE LESS THAN 2 GOALIES"
            completion(true)
            return
        }
        
        // Process all forward roster updates
        for (index, forward) in sortedForwardLineups.enumerated() {
            if index < sortedOtherForwardLineups.count {
                let otherForward = sortedOtherForwardLineups[index]
                updatePlayerAndLineupData(playerID: forward.playerID, newTeamID: otherTeamID, position: otherForward.position ?? "", lineNumber: otherForward.lineNumber, ppLineNumber: otherForward.powerPlayLineNumber, pkLineNumber: otherForward.penaltyKillLineNumber, otLineNumber: otherForward.otLineNumber)
                updatePlayerAndLineupData(playerID: otherForward.playerID, newTeamID: teamID, position: forward.position ?? "", lineNumber: forward.lineNumber, ppLineNumber: forward.powerPlayLineNumber, pkLineNumber: forward.penaltyKillLineNumber, otLineNumber: forward.otLineNumber)
            } else {
                if forward.lineNumber != 0 {
                    if let scratchedFoward = forwardLineups.first(where: { $0.lineNumber == 0 }) {
                        updatePlayerAndLineupData(playerID: scratchedFoward.playerID, newTeamID: teamID, position: forward.position ?? "", lineNumber: forward.lineNumber, ppLineNumber: forward.powerPlayLineNumber, pkLineNumber: forward.penaltyKillLineNumber, otLineNumber: forward.otLineNumber)
                    } else if let scratchedDefenseman = defenseLineups.first(where: { $0.lineNumber == 0 }) {
                        updatePlayerAndLineupData(playerID: scratchedDefenseman.playerID, newTeamID: teamID, position: forward.position ?? "", lineNumber: forward.lineNumber, ppLineNumber: forward.powerPlayLineNumber, pkLineNumber: forward.penaltyKillLineNumber, otLineNumber: forward.otLineNumber)
                    }
                }
                updatePlayerAndLineupData(playerID: forward.playerID, newTeamID: otherTeamID, position: forward.position ?? "", lineNumber: 0, ppLineNumber: 0, pkLineNumber: 0, otLineNumber: 0)
            }
        }
        
        // Process all remaining forward roster updates
        for (index, otherForward) in sortedOtherForwardLineups.enumerated() where index >= sortedForwardLineups.count {
            if otherForward.lineNumber != 0 {
                if let scratchedForward = otherForwardLineups.first(where: { $0.lineNumber == 0 }) {
                    updatePlayerAndLineupData(playerID: scratchedForward.playerID, newTeamID: otherTeamID, position: otherForward.position ?? "", lineNumber: otherForward.lineNumber, ppLineNumber: otherForward.powerPlayLineNumber, pkLineNumber: otherForward.penaltyKillLineNumber, otLineNumber: otherForward.otLineNumber)
                } else if let scratchedDefenseman = otherDefenseLineups.first(where: { $0.lineNumber == 0 }) {
                    updatePlayerAndLineupData(playerID: scratchedDefenseman.playerID, newTeamID: otherTeamID, position: otherForward.position ?? "", lineNumber: otherForward.lineNumber, ppLineNumber: otherForward.powerPlayLineNumber, pkLineNumber: otherForward.penaltyKillLineNumber, otLineNumber: otherForward.otLineNumber)
                }
            }
            updatePlayerAndLineupData(playerID: otherForward.playerID, newTeamID: teamID, position: otherForward.position ?? "", lineNumber: 0, ppLineNumber: 0, pkLineNumber: 0, otLineNumber: 0)
        }
        
        // Process all defense roster updates
        for (index, defenseman) in sortedDefenseLineups.enumerated() {
            if index < sortedOtherDefenseLineups.count {
                let otherDefenseman = sortedOtherDefenseLineups[index]
                updatePlayerAndLineupData(playerID: defenseman.playerID, newTeamID: otherTeamID, position: otherDefenseman.position ?? "", lineNumber: otherDefenseman.lineNumber, ppLineNumber: otherDefenseman.powerPlayLineNumber, pkLineNumber: otherDefenseman.penaltyKillLineNumber, otLineNumber: otherDefenseman.otLineNumber)
                updatePlayerAndLineupData(playerID: otherDefenseman.playerID, newTeamID: teamID, position: defenseman.position ?? "", lineNumber: defenseman.lineNumber, ppLineNumber: defenseman.powerPlayLineNumber, pkLineNumber: defenseman.penaltyKillLineNumber, otLineNumber: defenseman.otLineNumber)
            } else {
                if defenseman.lineNumber != 0 {
                    if let scratchedDefenseman = defenseLineups.first(where: { $0.lineNumber == 0 }) {
                        updatePlayerAndLineupData(playerID: scratchedDefenseman.playerID, newTeamID: teamID, position: defenseman.position ?? "", lineNumber: defenseman.lineNumber, ppLineNumber: defenseman.powerPlayLineNumber, pkLineNumber: defenseman.penaltyKillLineNumber, otLineNumber: defenseman.otLineNumber)
                    } else if let scratchedForward = forwardLineups.first(where: { $0.lineNumber == 0 }) {
                        updatePlayerAndLineupData(playerID: scratchedForward.playerID, newTeamID: teamID, position: defenseman.position ?? "", lineNumber: defenseman.lineNumber, ppLineNumber: defenseman.powerPlayLineNumber, pkLineNumber: defenseman.penaltyKillLineNumber, otLineNumber: defenseman.otLineNumber)
                    }
                }
                updatePlayerAndLineupData(playerID: defenseman.playerID, newTeamID: otherTeamID, position: defenseman.position ?? "", lineNumber: 0, ppLineNumber: 0, pkLineNumber: 0, otLineNumber: 0)
            }
        }
        
        // Process all remaining defense roster updates
        for (index, otherDefenseman) in sortedOtherDefenseLineups.enumerated() where index >= sortedDefenseLineups.count {
            if otherDefenseman.lineNumber != 0 {
                if let scratchedDefenseman = otherDefenseLineups.first(where: { $0.lineNumber == 0 }) {
                    updatePlayerAndLineupData(playerID: scratchedDefenseman.playerID, newTeamID: otherTeamID, position: otherDefenseman.position ?? "", lineNumber: otherDefenseman.lineNumber, ppLineNumber: otherDefenseman.powerPlayLineNumber, pkLineNumber: otherDefenseman.penaltyKillLineNumber, otLineNumber: otherDefenseman.otLineNumber)
                } else if let scratchedForward = otherForwardLineups.first(where: { $0.lineNumber == 0 }) {
                    updatePlayerAndLineupData(playerID: scratchedForward.playerID, newTeamID: otherTeamID, position: otherDefenseman.position ?? "", lineNumber: otherDefenseman.lineNumber, ppLineNumber: otherDefenseman.powerPlayLineNumber, pkLineNumber: otherDefenseman.penaltyKillLineNumber, otLineNumber: otherDefenseman.otLineNumber)
                }
            }
            updatePlayerAndLineupData(playerID: otherDefenseman.playerID, newTeamID: teamID, position: otherDefenseman.position ?? "", lineNumber: 0, ppLineNumber: 0, pkLineNumber: 0, otLineNumber: 0)
        }
        
        // Process all goalies roster updates
        for (index, goalie) in sortedGoalieLineups.enumerated() {
            if index < sortedOtherGoalieLineups.count {
                let otherGoalie = sortedOtherGoalieLineups[index]
                updatePlayerAndLineupData(playerID: goalie.playerID, newTeamID: otherTeamID, position: PositionType.goalies.rawValue, lineNumber: otherGoalie.lineNumber, ppLineNumber: 0, pkLineNumber: 0, otLineNumber: 0)
                updatePlayerAndLineupData(playerID: otherGoalie.playerID, newTeamID: teamID, position: PositionType.goalies.rawValue, lineNumber: goalie.lineNumber, ppLineNumber: 0, pkLineNumber: 0, otLineNumber: 0)
            } else {
                if goalie.lineNumber != 0 {
                    if let scratchedGoalie = goalieLineups.first(where: { $0.lineNumber == 0 }) {
                        updatePlayerAndLineupData(playerID: scratchedGoalie.playerID, newTeamID: teamID, position: PositionType.goalies.rawValue, lineNumber: goalie.lineNumber, ppLineNumber: 0, pkLineNumber: 0, otLineNumber: 0)
                    }
                }
                updatePlayerAndLineupData(playerID: goalie.playerID, newTeamID: otherTeamID, position: PositionType.goalies.rawValue, lineNumber: 0, ppLineNumber: 0, pkLineNumber: 0, otLineNumber: 0)
            }
        }
        
        // Process all remaining goalies roster updates
        for (index, otherGoalie) in sortedOtherGoalieLineups.enumerated() where index >= sortedGoalieLineups.count {
            if otherGoalie.lineNumber != 0 {
                if let scratchedGoalie = otherGoalieLineups.first(where: { $0.lineNumber == 0 }) {
                    updatePlayerAndLineupData(playerID: scratchedGoalie.playerID, newTeamID: otherTeamID, position: PositionType.goalies.rawValue, lineNumber: otherGoalie.lineNumber, ppLineNumber: 0, pkLineNumber: 0, otLineNumber: 0)
                }
            }
            updatePlayerAndLineupData(playerID: otherGoalie.playerID, newTeamID: teamID, position: PositionType.goalies.rawValue, lineNumber: 0, ppLineNumber: 0, pkLineNumber: 0, otLineNumber: 0)
        }
        
        switchMessage = "SUCCESS: PLAYERS SWITCHED"
        completion(true)
    }
    
    // Update player and lineup data
    private func updatePlayerAndLineupData(playerID: Int64, newTeamID: Int, position: String, lineNumber: Int16, ppLineNumber: Int16, pkLineNumber: Int16, otLineNumber: Int16) {
        CoreDataManager.shared.updateLineupsCoreData(
            playerID: Int(playerID),
            teamID: Int64(newTeamID),
            position: position,
            lineNumber: lineNumber,
            powerPlayLineNumber: ppLineNumber,
            penaltyKillLineNumber: pkLineNumber,
            otLineNumber: otLineNumber
        )
        CoreDataManager.shared.updatePlayerCoreData(playerID: playerID, teamID: newTeamID)
    }
}
