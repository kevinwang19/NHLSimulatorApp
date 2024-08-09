//
//  PlayerLineupSwapViewModel.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-08-08.
//

import Foundation
import RxSwift
import SwiftUI

class PlayerLineupSwapViewModel: ObservableObject {
    @Published var teams: [Team] = []
    @Published var lineupPlayers: [CoreLineup] = []
    private let disposeBag = DisposeBag()
    
    // Fetch all teams
    func fetchTeams(completion: @escaping (Bool) -> Void) {
        NetworkManager.shared.getAllTeams().subscribe(onSuccess: { [weak self] teamData in
            guard let self = self else {
                completion(false)
                return
            }
                
            self.teams = teamData.teams
            completion(true)
        }, onFailure: { error in
            print("Failed to fetch teams: \(error)")
            completion(false)
        })
        .disposed(by: disposeBag)
    }
    
    // Fetch team lineup of select position types
    func fetchTeamPositionPlayers(teamID: Int, positionType: String, completion: @escaping (Bool) -> Void) {
        var includedPositions: [String] = []
        
        // Lineup swap for any skater position will be all skaters, goalie swaps only for goalies
        if positionType == PositionType.goalies.rawValue {
            includedPositions = [PositionType.goalies.rawValue]
        } else {
            includedPositions = [PositionType.centers.rawValue, PositionType.leftWingers.rawValue, PositionType.rightWingers.rawValue, PositionType.leftDefensemen.rawValue, PositionType.rightDefensemen.rawValue]
        }
        
        let teamPositionLineups = CoreDataManager.shared.fetchTeamPositionLineupsCoreData(teamID: teamID, positions: includedPositions)
        
        // Extract playerIDs from lineups and fetch player details
        let playerIDs = teamPositionLineups.map { $0.playerID }
        let players = CoreDataManager.shared.fetchCertainPlayersCoreData(playerIDs: playerIDs)
        let playerDictionary = Dictionary(uniqueKeysWithValues: players.map { ($0.playerID, $0) })
        
        // Sort the players by last name
        let sortedLineupPlayers = teamPositionLineups.sorted { lineupPlayer1, lineupPlayer2 in
            let player1 = playerDictionary[lineupPlayer1.playerID]
            let player2 = playerDictionary[lineupPlayer2.playerID]
            
            return (player1?.lastName ?? "").localizedStandardCompare(player2?.lastName ?? "") == .orderedAscending
        }
        
        lineupPlayers = sortedLineupPlayers
        
        completion(true)
    }
    
    // Return the player's name
    func playerName(playerID: Int) -> String {
        let player = CoreDataManager.shared.fetchPlayerCoreData(playerID: playerID)
        let name = "\(player?.firstName?.prefix(1) ?? ""). \(player?.lastName ?? "")".uppercased()
        
        return name
    }
    
    // Swap player lineups
    func swapLineup(lineupType: LineupType, playerID: Int, swapPlayerID: Int, completion: @escaping (Bool) -> Void) {
        guard let player = CoreDataManager.shared.fetchPlayerLineupCoreData(playerID: playerID),
              let swapPlayer = CoreDataManager.shared.fetchPlayerLineupCoreData(playerID: swapPlayerID) else {
            completion(false)
            return
        }
        
        var playerPosition: String = ""
        var playerLineNumber: Int16 = 0
        var playerPowerPlayNumber: Int16 = 0
        var playerPenaltyKillNumber: Int16 = 0
        var playerOTNumber: Int16 = 0
        
        var swapPlayerPosition: String = ""
        var swapPlayerLineNumber: Int16 = 0
        var swapPlayerPowerPlayNumber: Int16 = 0
        var swapPlayerPenaltyKillNumber: Int16 = 0
        var swapPlayerOTNumber: Int16 = 0
        
        // If the player to be swapped is not in the current lineup, replace all lineups with the swapping player, otherwise, only swap the required lineup type
        if swapPlayer.lineNumber == 0 {
            playerPosition = player.position ?? ""
            playerLineNumber = 0
            playerPowerPlayNumber = 0
            playerPenaltyKillNumber = 0
            playerOTNumber = 0
            
            swapPlayerPosition = player.position ?? ""
            swapPlayerLineNumber = player.lineNumber
            swapPlayerPowerPlayNumber = player.powerPlayLineNumber
            swapPlayerPenaltyKillNumber = player.penaltyKillLineNumber
            swapPlayerOTNumber = player.otLineNumber
        } else {
            if lineupType == .evenStrength {
                playerPosition = swapPlayer.position ?? ""
                playerLineNumber = swapPlayer.lineNumber
                playerPowerPlayNumber = player.powerPlayLineNumber
                playerPenaltyKillNumber = player.penaltyKillLineNumber
                playerOTNumber = player.otLineNumber
                
                swapPlayerPosition = player.position ?? ""
                swapPlayerLineNumber = player.lineNumber
                swapPlayerPowerPlayNumber = swapPlayer.powerPlayLineNumber
                swapPlayerPenaltyKillNumber = swapPlayer.penaltyKillLineNumber
                swapPlayerOTNumber = swapPlayer.otLineNumber
            } else if lineupType == .powerplay {
                playerPosition = player.position ?? ""
                playerLineNumber = player.lineNumber
                playerPowerPlayNumber = swapPlayer.powerPlayLineNumber
                playerPenaltyKillNumber = player.penaltyKillLineNumber
                playerOTNumber = player.otLineNumber
                
                swapPlayerPosition = swapPlayer.position ?? ""
                swapPlayerLineNumber = swapPlayer.lineNumber
                swapPlayerPowerPlayNumber = player.powerPlayLineNumber
                swapPlayerPenaltyKillNumber = swapPlayer.penaltyKillLineNumber
                swapPlayerOTNumber = swapPlayer.otLineNumber
            } else if lineupType == .penaltyKill {
                playerPosition = player.position ?? ""
                playerLineNumber = player.lineNumber
                playerPowerPlayNumber = player.powerPlayLineNumber
                playerPenaltyKillNumber = swapPlayer.penaltyKillLineNumber
                playerOTNumber = player.otLineNumber
                
                swapPlayerPosition = swapPlayer.position ?? ""
                swapPlayerLineNumber = swapPlayer.lineNumber
                swapPlayerPowerPlayNumber = swapPlayer.powerPlayLineNumber
                swapPlayerPenaltyKillNumber = player.penaltyKillLineNumber
                swapPlayerOTNumber = swapPlayer.otLineNumber
            } else if lineupType == .overtime {
                playerPosition = player.position ?? ""
                playerLineNumber = player.lineNumber
                playerPowerPlayNumber = player.powerPlayLineNumber
                playerPenaltyKillNumber = player.penaltyKillLineNumber
                playerOTNumber = swapPlayer.otLineNumber
                
                swapPlayerPosition = swapPlayer.position ?? ""
                swapPlayerLineNumber = swapPlayer.lineNumber
                swapPlayerPowerPlayNumber = swapPlayer.powerPlayLineNumber
                swapPlayerPenaltyKillNumber = swapPlayer.penaltyKillLineNumber
                swapPlayerOTNumber = player.otLineNumber
            }
        }
        
        CoreDataManager.shared.updateLineupsCoreData(playerID: playerID, position: playerPosition, lineNumber: playerLineNumber, powerPlayLineNumber: playerPowerPlayNumber, penaltyKillLineNumber: playerPenaltyKillNumber, otLineNumber: playerOTNumber)
        CoreDataManager.shared.updateLineupsCoreData(playerID: swapPlayerID, position: swapPlayerPosition, lineNumber: swapPlayerLineNumber, powerPlayLineNumber: swapPlayerPowerPlayNumber, penaltyKillLineNumber: swapPlayerPenaltyKillNumber, otLineNumber: swapPlayerOTNumber)
        
        completion(true)
    }
}
