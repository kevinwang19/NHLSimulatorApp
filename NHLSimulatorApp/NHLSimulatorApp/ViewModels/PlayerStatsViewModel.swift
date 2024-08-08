//
//  PlayerStatsViewModel.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-08-05.
//

import Foundation
import RxSwift
import SwiftUI

class PlayerStatsViewModel: ObservableObject {
    @Published var teams: [Team] = []
    @Published var simSkaterStats: [SimulationSkaterStat] = []
    @Published var simGoalieStats: [SimulationGoalieStat] = []
    private let disposeBag = DisposeBag()
    
    // Fetch all teams
    func fetchTeams(completion: @escaping (Bool) -> Void) {
        NetworkManager.shared.getAllTeams().subscribe(onSuccess: { [weak self] teamData in
            guard let self = self else {
                completion(false)
                return
            }
                
            self.teams = teamData.teams
            self.teams.append(Team(teamID: 0, fullName: NSLocalizedString(StatColumnHeader.top50.rawValue, comment: ""), abbrev: "", logo: "", conference: "", division: ""))
            completion(true)
        }, onFailure: { error in
            print("Failed to fetch teams: \(error)")
            completion(false)
        })
        .disposed(by: disposeBag)
    }
    
    // Fetch all skater and goalie simulation stats
    func fetchPlayerSimStats(simulationID: Int, teamID: Int, completion: @escaping (Bool) -> Void) {
        let players = CoreDataManager.shared.fetchTeamPlayersCoreData(teamID: teamID)
        let skaterIDs = players.filter { $0.positionCode != "G" }.map { Int($0.playerID) }
        let goalieIDs = players.filter { $0.positionCode == "G" }.map { Int($0.playerID) }
        
        NetworkManager.shared.getSimTeamSkaterStats(simulationID: simulationID, playerIDs: skaterIDs, teamID: teamID).subscribe(onSuccess: { [weak self] simulationSkaterStats in
            guard let self = self else {
                completion(false)
                return
            }
                
            self.simSkaterStats = simulationSkaterStats.skaterStats
        }, onFailure: { error in
            print("Failed to fetch skater simulation stats: \(error)")
            completion(false)
        })
        .disposed(by: disposeBag)
        
        NetworkManager.shared.getSimTeamGoalieStats(simulationID: simulationID, playerIDs: goalieIDs, teamID: teamID).subscribe(onSuccess: { [weak self] simulationGoalieStats in
            guard let self = self else {
                completion(false)
                return
            }
                    
            self.simGoalieStats = simulationGoalieStats.goalieStats
            completion(true)
        }, onFailure: { error in
            print("Failed to fetch goalie simulation stats: \(error)")
            completion(false)
        })
        .disposed(by: disposeBag)
    }
    
    // Fetch skater simulation stats for a selected position
    func fetchSkaterPositionSimStats(simulationID: Int, teamID: Int, position: String) -> Void {
        let players = CoreDataManager.shared.fetchTeamPlayersCoreData(teamID: teamID)
        let skaterIDs = players.filter { $0.positionCode != "G" }.map { Int($0.playerID) }
        
        let includedPositions: [String] = {
            switch position {
            case PositionType.all.rawValue:
                return [PositionType.centers.rawValue, PositionType.leftWingers.rawValue, PositionType.rightWingers.rawValue, PositionType.defensemen.rawValue]
            case PositionType.forwards.rawValue:
                return [PositionType.centers.rawValue, PositionType.leftWingers.rawValue, PositionType.rightWingers.rawValue]
            case PositionType.centers.rawValue:
                return [PositionType.centers.rawValue]
            case PositionType.leftWingers.rawValue:
                return [PositionType.leftWingers.rawValue]
            case PositionType.rightWingers.rawValue:
                return [PositionType.rightWingers.rawValue]
            case PositionType.defensemen.rawValue:
                return [PositionType.defensemen.rawValue]
            default:
                return [PositionType.centers.rawValue, PositionType.leftWingers.rawValue, PositionType.rightWingers.rawValue, PositionType.defensemen.rawValue]
            }
        }()
                
        NetworkManager.shared.getSimTeamPositionSkaterStats(simulationID: simulationID, playerIDs: skaterIDs, teamID: teamID, position: includedPositions).subscribe(onSuccess: { [weak self] simulationSkaterStats in
            guard let self = self else {
                return
            }
                
            self.simSkaterStats = simulationSkaterStats.skaterStats
        }, onFailure: { error in
            print("Failed to fetch skater simulation stats: \(error)")
        })
        .disposed(by: disposeBag)
    }
}
