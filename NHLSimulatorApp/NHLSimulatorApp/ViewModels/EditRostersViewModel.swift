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
            switchMessage = LocalizedText.noSwapError.localizedString
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
        }.sorted { $0.lineNumber < $1.lineNumber }
        let sortedDefenseLineups = playerLineups.filter {
            $0.position == PositionType.leftDefensemen.rawValue ||
            $0.position == PositionType.rightDefensemen.rawValue
        }.sorted { $0.lineNumber < $1.lineNumber }
        let sortedGoalieLineups = playerLineups.filter {
            $0.position == PositionType.goalies.rawValue
        }.sorted { $0.lineNumber < $1.lineNumber }
        
        let sortedOtherForwardLineups = otherPlayerLineups.filter {
            $0.position == PositionType.centers.rawValue ||
            $0.position == PositionType.leftWingers.rawValue ||
            $0.position == PositionType.rightWingers.rawValue
        }.sorted { $0.lineNumber < $1.lineNumber }
        let sortedOtherDefenseLineups = otherPlayerLineups.filter {
            $0.position == PositionType.leftDefensemen.rawValue ||
            $0.position == PositionType.rightDefensemen.rawValue
        }.sorted { $0.lineNumber < $1.lineNumber }
        let sortedOtherGoalieLineups = otherPlayerLineups.filter {
            $0.position == PositionType.goalies.rawValue
        }.sorted { $0.lineNumber < $1.lineNumber }
        
        // Validation checks
        guard skaterLineups.count - (sortedForwardLineups.count + sortedDefenseLineups.count) + (sortedOtherForwardLineups.count + sortedOtherDefenseLineups.count) >= minSkaters else {
            switchMessage = LocalizedText.minSkaters1SwapError.localizedString
            completion(true)
            return
        }
        
        guard goalieLineups.count - sortedGoalieLineups.count + sortedOtherGoalieLineups.count >= minGoalies else {
            switchMessage = LocalizedText.minGoalies1SwapError.localizedString
            completion(true)
            return
        }
        
        guard otherSkaterLineups.count - (sortedOtherForwardLineups.count + sortedOtherDefenseLineups.count) + (sortedForwardLineups.count + sortedDefenseLineups.count) >= minSkaters else {
            switchMessage = LocalizedText.minSkaters2SwapError.localizedString
            completion(true)
            return
        }
        
        guard otherGoalieLineups.count - sortedOtherGoalieLineups.count + sortedGoalieLineups.count >= minGoalies else {
            switchMessage = LocalizedText.minGoalies2SwapError.localizedString
            completion(true)
            return
        }
        
        // Process all forward roster updates
        for (index, forward) in sortedForwardLineups.enumerated() {
            let forwardPosition = forward.position ?? ""
            let forwardLineNumber = forward.lineNumber
            let forwardPPLineNumber = forward.powerPlayLineNumber
            let forwardPKLineNumber = forward.penaltyKillLineNumber
            let forwardOTLineNumber = forward.otLineNumber
            
            if index < sortedOtherForwardLineups.count {
                let otherForward = sortedOtherForwardLineups[index]
                let otherForwardPosition = otherForward.position ?? ""
                let otherForwardLineNumber = otherForward.lineNumber
                let otherForwardPPLineNumber = otherForward.powerPlayLineNumber
                let otherForwardPKLineNumber = otherForward.penaltyKillLineNumber
                let otherForwardOTLineNumber = otherForward.otLineNumber
                
                updatePlayerAndLineupData(playerID: forward.playerID, newTeamID: otherTeamID, position: otherForwardPosition, lineNumber: otherForwardLineNumber, ppLineNumber: otherForwardPPLineNumber, pkLineNumber: otherForwardPKLineNumber, otLineNumber: otherForwardOTLineNumber)
                updatePlayerAndLineupData(playerID: otherForward.playerID, newTeamID: teamID, position: forwardPosition, lineNumber: forwardLineNumber, ppLineNumber: forwardPPLineNumber, pkLineNumber: forwardPKLineNumber, otLineNumber: forwardOTLineNumber)
            } else {
                if forward.lineNumber != 0 {
                    if let scratchedFoward = forwardLineups.first(where: { $0.lineNumber == 0 }) {
                        updatePlayerAndLineupData(playerID: scratchedFoward.playerID, newTeamID: teamID, position: forwardPosition, lineNumber: forwardLineNumber, ppLineNumber: forwardPPLineNumber, pkLineNumber: forwardPKLineNumber, otLineNumber: forwardOTLineNumber)
                    } else if let scratchedDefenseman = defenseLineups.first(where: { $0.lineNumber == 0 }) {
                        updatePlayerAndLineupData(playerID: scratchedDefenseman.playerID, newTeamID: teamID, position: forwardPosition, lineNumber: forwardLineNumber, ppLineNumber: forwardPPLineNumber, pkLineNumber: forwardPKLineNumber, otLineNumber: forwardOTLineNumber)
                    }
                }
                updatePlayerAndLineupData(playerID: forward.playerID, newTeamID: otherTeamID, position: forwardPosition, lineNumber: 0, ppLineNumber: 0, pkLineNumber: 0, otLineNumber: 0)
            }
        }
        
        // Process all remaining forward roster updates
        for (index, otherForward) in sortedOtherForwardLineups.enumerated() where index >= sortedForwardLineups.count {
            let otherForwardPosition = otherForward.position ?? ""
            let otherForwardLineNumber = otherForward.lineNumber
            let otherForwardPPLineNumber = otherForward.powerPlayLineNumber
            let otherForwardPKLineNumber = otherForward.penaltyKillLineNumber
            let otherForwardOTLineNumber = otherForward.otLineNumber
            
            if otherForward.lineNumber != 0 {
                if let scratchedForward = otherForwardLineups.first(where: { $0.lineNumber == 0 }) {
                    updatePlayerAndLineupData(playerID: scratchedForward.playerID, newTeamID: otherTeamID, position: otherForwardPosition, lineNumber: otherForwardLineNumber, ppLineNumber: otherForwardPPLineNumber, pkLineNumber: otherForwardPKLineNumber, otLineNumber: otherForwardOTLineNumber)
                } else if let scratchedDefenseman = otherDefenseLineups.first(where: { $0.lineNumber == 0 }) {
                    updatePlayerAndLineupData(playerID: scratchedDefenseman.playerID, newTeamID: otherTeamID, position: otherForwardPosition, lineNumber: otherForwardLineNumber, ppLineNumber: otherForwardPPLineNumber, pkLineNumber: otherForwardPKLineNumber, otLineNumber: otherForwardOTLineNumber)
                }
            }
            updatePlayerAndLineupData(playerID: otherForward.playerID, newTeamID: teamID, position: otherForwardPosition, lineNumber: 0, ppLineNumber: 0, pkLineNumber: 0, otLineNumber: 0)
        }
        
        // Process all defense roster updates
        for (index, defenseman) in sortedDefenseLineups.enumerated() {
            let defensemanPosition = defenseman.position ?? ""
            let defensemanLineNumber = defenseman.lineNumber
            let defensemanPPLineNumber = defenseman.powerPlayLineNumber
            let defensemanPKLineNumber = defenseman.penaltyKillLineNumber
            let defensemanOTLineNumber = defenseman.otLineNumber
            
            if index < sortedOtherDefenseLineups.count {
                let otherDefenseman = sortedOtherDefenseLineups[index]
                let otherDefensemanPosition = otherDefenseman.position ?? ""
                let otherDefensemanLineNumber = otherDefenseman.lineNumber
                let otherDefensemanPPLineNumber = otherDefenseman.powerPlayLineNumber
                let otherDefensemanPKLineNumber = otherDefenseman.penaltyKillLineNumber
                let otherDefensemanOTLineNumber = otherDefenseman.otLineNumber
                
                updatePlayerAndLineupData(playerID: defenseman.playerID, newTeamID: otherTeamID, position: otherDefensemanPosition, lineNumber: otherDefensemanLineNumber, ppLineNumber: otherDefensemanPPLineNumber, pkLineNumber: otherDefensemanPKLineNumber, otLineNumber: otherDefensemanOTLineNumber)
                updatePlayerAndLineupData(playerID: otherDefenseman.playerID, newTeamID: teamID, position: defensemanPosition, lineNumber: defensemanLineNumber, ppLineNumber: defensemanPPLineNumber, pkLineNumber: defensemanPKLineNumber, otLineNumber: defensemanOTLineNumber)
            } else {
                if defenseman.lineNumber != 0 {
                    if let scratchedDefenseman = defenseLineups.first(where: { $0.lineNumber == 0 }) {
                        updatePlayerAndLineupData(playerID: scratchedDefenseman.playerID, newTeamID: teamID, position: defensemanPosition, lineNumber: defensemanLineNumber, ppLineNumber: defensemanPPLineNumber, pkLineNumber: defensemanPKLineNumber, otLineNumber: defensemanOTLineNumber)
                    } else if let scratchedForward = forwardLineups.first(where: { $0.lineNumber == 0 }) {
                        updatePlayerAndLineupData(playerID: scratchedForward.playerID, newTeamID: teamID, position: defensemanPosition, lineNumber: defensemanLineNumber, ppLineNumber: defensemanPPLineNumber, pkLineNumber: defensemanPKLineNumber, otLineNumber: defensemanOTLineNumber)
                    }
                }
                updatePlayerAndLineupData(playerID: defenseman.playerID, newTeamID: otherTeamID, position: defensemanPosition, lineNumber: 0, ppLineNumber: 0, pkLineNumber: 0, otLineNumber: 0)
            }
        }
        
        // Process all remaining defense roster updates
        for (index, otherDefenseman) in sortedOtherDefenseLineups.enumerated() where index >= sortedDefenseLineups.count {
            let otherDefensemanPosition = otherDefenseman.position ?? ""
            let otherDefensemanLineNumber = otherDefenseman.lineNumber
            let otherDefensemanPPLineNumber = otherDefenseman.powerPlayLineNumber
            let otherDefensemanPKLineNumber = otherDefenseman.penaltyKillLineNumber
            let otherDefensemanOTLineNumber = otherDefenseman.otLineNumber
            
            if otherDefenseman.lineNumber != 0 {
                if let scratchedDefenseman = otherDefenseLineups.first(where: { $0.lineNumber == 0 }) {
                    updatePlayerAndLineupData(playerID: scratchedDefenseman.playerID, newTeamID: otherTeamID, position: otherDefensemanPosition, lineNumber: otherDefensemanLineNumber, ppLineNumber: otherDefensemanPPLineNumber, pkLineNumber: otherDefensemanPKLineNumber, otLineNumber: otherDefensemanOTLineNumber)
                } else if let scratchedForward = otherForwardLineups.first(where: { $0.lineNumber == 0 }) {
                    updatePlayerAndLineupData(playerID: scratchedForward.playerID, newTeamID: otherTeamID, position: otherDefensemanPosition, lineNumber: otherDefensemanLineNumber, ppLineNumber: otherDefensemanPPLineNumber, pkLineNumber: otherDefensemanPKLineNumber, otLineNumber: otherDefensemanOTLineNumber)
                }
            }
            updatePlayerAndLineupData(playerID: otherDefenseman.playerID, newTeamID: teamID, position: otherDefensemanPosition, lineNumber: 0, ppLineNumber: 0, pkLineNumber: 0, otLineNumber: 0)
        }
        
        // Process all goalies roster updates
        for (index, goalie) in sortedGoalieLineups.enumerated() {
            let goalieLineNumber = goalie.lineNumber
            
            if index < sortedOtherGoalieLineups.count {
                let otherGoalie = sortedOtherGoalieLineups[index]
                let otherGoalieLineNumber = otherGoalie.lineNumber
                
                updatePlayerAndLineupData(playerID: goalie.playerID, newTeamID: otherTeamID, position: PositionType.goalies.rawValue, lineNumber: otherGoalieLineNumber, ppLineNumber: 0, pkLineNumber: 0, otLineNumber: 0)
                updatePlayerAndLineupData(playerID: otherGoalie.playerID, newTeamID: teamID, position: PositionType.goalies.rawValue, lineNumber: goalieLineNumber, ppLineNumber: 0, pkLineNumber: 0, otLineNumber: 0)
            } else {
                if goalie.lineNumber != 0 {
                    if let scratchedGoalie = goalieLineups.first(where: { $0.lineNumber == 0 }) {
                        updatePlayerAndLineupData(playerID: scratchedGoalie.playerID, newTeamID: teamID, position: PositionType.goalies.rawValue, lineNumber: goalieLineNumber, ppLineNumber: 0, pkLineNumber: 0, otLineNumber: 0)
                    }
                }
                updatePlayerAndLineupData(playerID: goalie.playerID, newTeamID: otherTeamID, position: PositionType.goalies.rawValue, lineNumber: 0, ppLineNumber: 0, pkLineNumber: 0, otLineNumber: 0)
            }
        }
        
        // Process all remaining goalies roster updates
        for (index, otherGoalie) in sortedOtherGoalieLineups.enumerated() where index >= sortedGoalieLineups.count {
            let otherGoalieLineNumber = otherGoalie.lineNumber
            
            if otherGoalie.lineNumber != 0 {
                if let scratchedGoalie = otherGoalieLineups.first(where: { $0.lineNumber == 0 }) {
                    updatePlayerAndLineupData(playerID: scratchedGoalie.playerID, newTeamID: otherTeamID, position: PositionType.goalies.rawValue, lineNumber: otherGoalieLineNumber, ppLineNumber: 0, pkLineNumber: 0, otLineNumber: 0)
                }
            }
            updatePlayerAndLineupData(playerID: otherGoalie.playerID, newTeamID: teamID, position: PositionType.goalies.rawValue, lineNumber: 0, ppLineNumber: 0, pkLineNumber: 0, otLineNumber: 0)
        }
        
        switchMessage = LocalizedText.swapSuccess.localizedString
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
