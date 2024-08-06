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
    @Published var sortedSimSkaterStats: [SimulationSkaterStat] = []
    @Published var simGoalieStats: [SimulationGoalieStat] = []
    private let disposeBag = DisposeBag()
    
    init() {
        fetchTeams()
    }
    
    // Fetch all teams
    func fetchTeams() {
        NetworkManager.shared.getAllTeams().subscribe(onSuccess: { [weak self] teamData in
            guard let self = self else { return }
                
            self.teams = teamData.teams
        }, onFailure: { error in
            print("Failed to fetch teams: \(error)")
        })
        .disposed(by: disposeBag)
    }
    
    // Fetch all skater and goalie simulation stats
    func fetchPlayerSimStats(simulationID: Int, teamID: Int, completion: @escaping (Bool) -> Void) {
        NetworkManager.shared.getSimTeamSkaterStats(simulationID: simulationID, teamID: teamID).subscribe(onSuccess: { [weak self] simulationSkaterStats in
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
        
        
        NetworkManager.shared.getSimTeamGoalieStats(simulationID: simulationID, teamID: teamID).subscribe(onSuccess: { [weak self] simulationGoalieStats in
            guard let self = self else {
                completion(false)
                return
            }
                    
            self.simGoalieStats = simulationGoalieStats.goalieStats
        }, onFailure: { error in
            print("Failed to fetch goalie simulation stats: \(error)")
            completion(false)
        })
        .disposed(by: disposeBag)
        
        completion(true)
    }
    
    // Fetch skater simulation stats for a selected position
    func fetchSkaterPositionSimStats(simulationID: Int, teamID: Int, position: String) -> Void {
        let includedPositions: [String] = {
            switch position {
            case PositionType.all.rawValue:
                return ["C", "L", "R", "D"]
            case PositionType.forwards.rawValue:
                return ["C", "L", "R"]
            case PositionType.centers.rawValue:
                return ["C"]
            case PositionType.leftWingers.rawValue:
                return ["L"]
            case PositionType.rightWingers.rawValue:
                return ["R"]
            case PositionType.defensemen.rawValue:
                return ["D"]
            default:
                return ["C", "L", "R", "D"]
            }
        }()
                
        NetworkManager.shared.getSimTeamPositionSkaterStats(simulationID: simulationID, teamID: teamID, position: includedPositions).subscribe(onSuccess: { [weak self] simulationSkaterStats in
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
