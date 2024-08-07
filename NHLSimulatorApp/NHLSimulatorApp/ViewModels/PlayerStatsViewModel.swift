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
    
    init() {
        fetchTeams()
    }
    
    // Fetch all teams
    func fetchTeams() {
        NetworkManager.shared.getAllTeams().subscribe(onSuccess: { [weak self] teamData in
            guard let self = self else { return }
                
            self.teams = teamData.teams
            self.teams.insert(Team(teamID: 0, fullName: NSLocalizedString(StatColumnHeader.top50.rawValue, comment: ""), abbrev: "", logo: "", conference: "", division: ""), at: 0)
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
                return [
                    NSLocalizedString(PositionType.centers.rawValue, comment: ""),
                    NSLocalizedString(PositionType.leftWingers.rawValue, comment: ""),
                    NSLocalizedString(PositionType.rightWingers.rawValue, comment: ""),
                    NSLocalizedString(PositionType.defensemen.rawValue, comment: "")
                ]
            case PositionType.forwards.rawValue:
                return [
                    NSLocalizedString(PositionType.centers.rawValue, comment: ""),
                    NSLocalizedString(PositionType.leftWingers.rawValue, comment: ""),
                    NSLocalizedString(PositionType.rightWingers.rawValue, comment: "")
                ]
            case PositionType.centers.rawValue:
                return [NSLocalizedString(PositionType.centers.rawValue, comment: "")]
            case PositionType.leftWingers.rawValue:
                return [NSLocalizedString(PositionType.leftWingers.rawValue, comment: "")]
            case PositionType.rightWingers.rawValue:
                return [NSLocalizedString(PositionType.rightWingers.rawValue, comment: "")]
            case PositionType.defensemen.rawValue:
                return [ NSLocalizedString(PositionType.defensemen.rawValue, comment: "")]
            default:
                return [
                    NSLocalizedString(PositionType.centers.rawValue, comment: ""),
                    NSLocalizedString(PositionType.leftWingers.rawValue, comment: ""),
                    NSLocalizedString(PositionType.rightWingers.rawValue, comment: ""),
                    NSLocalizedString(PositionType.defensemen.rawValue, comment: "")
                ]
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
