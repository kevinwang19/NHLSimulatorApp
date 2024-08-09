//
//  EditLineupsViewModel.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-08-05.
//

import Foundation
import RxSwift
import SwiftUI

class EditLineupsViewModel: ObservableObject {
    @Published var teams: [Team] = []
    @Published var lineup: [CoreLineup] = []
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
    
    // Fetch team lineup
    func fetchTeamLineup(teamID: Int, completion: @escaping (Bool) -> Void) {
        lineup = CoreDataManager.shared.fetchTeamLineupsCoreData(teamID: teamID)
        completion(true)
    }
    
    // Return the player's ID and name
    func playerDetails(lineupType: LineupType, lineNumber: Int, position: String, positionIndex: Int?) -> [String] {
        var player: CorePlayer?
        
        // For even strength, use the specific position, otherwise for special teams, use the index
        if lineupType == .evenStrength {
            guard let lineupPlayer = lineup.first(where: { $0.lineNumber == lineNumber && $0.position == position }) else {
                return []
            }
            
            player = CoreDataManager.shared.fetchPlayerCoreData(playerID: Int(lineupPlayer.playerID))
        } else if lineupType == .powerplay {
            guard let positionIndex = positionIndex else {
                return []
            }
            let lineupPlayers = lineup.filter { $0.powerPlayLineNumber == lineNumber }
            let lineupPlayer = sortedSpecialTeamsLineups(lineupPlayers: lineupPlayers)[positionIndex]
            
            player = CoreDataManager.shared.fetchPlayerCoreData(playerID: Int(lineupPlayer.playerID))
        } else if lineupType == .penaltyKill {
            guard let positionIndex = positionIndex else {
                return []
            }
            let lineupPlayers = lineup.filter { $0.penaltyKillLineNumber == lineNumber }
            let lineupPlayer = sortedSpecialTeamsLineups(lineupPlayers: lineupPlayers)[positionIndex]
            
            player = CoreDataManager.shared.fetchPlayerCoreData(playerID: Int(lineupPlayer.playerID))
        } else if lineupType == .overtime {
            guard let positionIndex = positionIndex else {
                return []
            }
            let lineupPlayers = lineup.filter { $0.otLineNumber == lineNumber }
            let lineupPlayer = sortedSpecialTeamsLineups(lineupPlayers: lineupPlayers)[positionIndex]
            
            player = CoreDataManager.shared.fetchPlayerCoreData(playerID: Int(lineupPlayer.playerID))
        } else {
            return []
        }
        
        let id = "\(player?.playerID ?? 0)"
        let name = "\(player?.firstName?.prefix(1) ?? ""). \(player?.lastName ?? "")".uppercased()
        return [id, name]
    }
    
    // Sort the special teams lineup to place defensemen at the back
    func sortedSpecialTeamsLineups(lineupPlayers: [CoreLineup]) -> [CoreLineup] {
        let reorderedLineupPlayers = lineupPlayers.sorted { player1, player2 in
            let isPlayer1Defense = player1.position == PositionType.leftDefensemen.rawValue || player1.position == PositionType.rightDefensemen.rawValue
            let isPlayer2Defense = player2.position == PositionType.leftDefensemen.rawValue || player2.position == PositionType.rightDefensemen.rawValue
            
            if isPlayer1Defense && !isPlayer2Defense {
                return false
            } else if !isPlayer1Defense && isPlayer2Defense {
                return true
            } else {
                return true
            }
        }
        
        return reorderedLineupPlayers
    }
}
