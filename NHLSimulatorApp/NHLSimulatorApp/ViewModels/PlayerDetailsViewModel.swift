//
//  PlayerDetailsViewModel.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-08-07.
//

import Foundation
import RxSwift
import SwiftUI

class PlayerDetailsViewModel: ObservableObject {
    var team: Team?
    @Published var skaterCareerStats: [SkaterStat] = []
    @Published var skaterPredictedStats: [SkaterStat] = []
    @Published var goalieCareerStats: [GoalieStat] = []
    @Published var goaliePredictedStats: [GoalieStat] = []
    private let disposeBag = DisposeBag()
    
    // Return the Core Data player object
    func playerDetails(playerID: Int) -> CorePlayer? {
        return CoreDataManager.shared.fetchPlayerCoreData(playerID: playerID)
    }
    
    // Fetch the player's team details
    func fetchPlayerTeam(teamID: Int, completion: @escaping (Bool) -> Void) {
        NetworkManager.shared.getTeamData(teamID: teamID).subscribe(onSuccess: { [weak self] teamData in
            guard let self = self else {
                completion(false)
                return
            }
                
            self.team = teamData
            completion(true)
        }, onFailure: { error in
            print("Failed to fetch team: \(error)")
            completion(false)
        })
        .disposed(by: disposeBag)
    }
    
    // Fetch the skater or goalie's career and predicted stats
    func fetchPlayerStats(playerID: Int, position: String, completion: @escaping (Bool) -> Void) {
        if position != PositionType.goalies.rawValue {
            NetworkManager.shared.getSkaterCareerStats(playerID: playerID).subscribe(onSuccess: { [weak self] skaterCareerStatsData in
                guard let self = self else {
                    completion(false)
                    return
                }
                
                self.skaterCareerStats = skaterCareerStatsData.skaterStats
                self.goalieCareerStats = []
            }, onFailure: { error in
                print("Failed to fetch skater career stats: \(error)")
                completion(false)
            })
            .disposed(by: disposeBag)
            
            NetworkManager.shared.getSkaterPredictedStats(playerID: playerID).subscribe(onSuccess: { [weak self] skaterPredictedStatsData in
                guard let self = self else {
                    completion(false)
                    return
                }
                
                self.skaterPredictedStats = skaterPredictedStatsData.skaterStats
                self.goaliePredictedStats = []
                completion(true)
            }, onFailure: { error in
                print("Failed to fetch skater predicted stats: \(error)")
                completion(false)
            })
            .disposed(by: disposeBag)
        } else {
            NetworkManager.shared.getGoalieCareerStats(playerID: playerID).subscribe(onSuccess: { [weak self] goalieCareerStatsData in
                guard let self = self else {
                    completion(false)
                    return
                }
                
                self.skaterCareerStats = []
                self.goalieCareerStats = goalieCareerStatsData.goalieStats
            }, onFailure: { error in
                print("Failed to fetch goalie career stats: \(error)")
                completion(false)
            })
            .disposed(by: disposeBag)
            
            NetworkManager.shared.getGoaliePredictedStats(playerID: playerID).subscribe(onSuccess: { [weak self] goaliePredictedStatsData in
                guard let self = self else {
                    completion(false)
                    return
                }
                
                self.skaterPredictedStats = []
                self.goaliePredictedStats = goaliePredictedStatsData.goalieStats
                completion(true)
            }, onFailure: { error in
                print("Failed to fetch goalie predicted stats: \(error)")
                completion(false)
            })
            .disposed(by: disposeBag)
            
            completion(true)
        }
    }
}
