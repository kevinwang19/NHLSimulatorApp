//
//  MainSimViewModel.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-07-16.
//

import Foundation
import RxSwift
import SwiftUI

class MainSimViewModel: ObservableObject {
    @Published var selectedTeamIndex: Int = 0
    @Published var showDropdown: Bool = false
    @Published var selectedDate: Date = Date()
    @Published var isSimulationLoaded: Bool = false
    
    @Published var teams: [Team] = []
    @Published var simulationCurrentDate: String?
    @Published var season: Int?
    @Published var scheduleGames: [Schedule] = []
    @Published var matchupGame: Schedule?
    @Published var simTeamStat: SimulationTeamStat?
    @Published var simOpponentStat: SimulationTeamStat?
    private let disposeBag = DisposeBag()
    
    let calendar = Calendar(identifier: .gregorian)
    let dateFormatter = DateFormatter(dateFormat: "yyyy-MM-dd", calendar: Calendar(identifier: .gregorian))
    let monthFormatter = DateFormatter(dateFormat: "MMM yyyy", calendar: Calendar(identifier: .gregorian))
    let dayFormatter = DateFormatter(dateFormat: "d", calendar: Calendar(identifier: .gregorian))
    let weekDayFormatter = DateFormatter(dateFormat: "EEEEE", calendar: Calendar(identifier: .gregorian))
    
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
    
    // Create the simulation
    func generateSimulation(userInfo: UserInfo, completion: @escaping (Bool) -> Void) {
        NetworkManager.shared.createSimulation(userID: userInfo.userID).subscribe(onSuccess: { simulationData in
            userInfo.setSimulationStartInfo(simulationID: simulationData.simulationID, season: simulationData.season)
            completion(true)
        }, onFailure: { error in
            print("Failed to generate simulation: \(error)")
            completion(false)
        })
        .disposed(by: disposeBag)
    }
    
    // Fetch the date of the simulation
    func fetchSimulationDateDetails(userInfo: UserInfo, completion: @escaping (Bool) -> Void) {
        NetworkManager.shared.getRecentSimulation(userID: userInfo.userID).subscribe(onSuccess: { [weak self] simulationData in
            guard let self = self else {
                completion(false)
                return
            }
            
            self.simulationCurrentDate = simulationData.simulationCurrentDate
            self.season = simulationData.season
            completion(true)
        }, onFailure: { error in
            print("Failed to fetch simulation: \(error)")
            completion(false)
        })
        .disposed(by: disposeBag)
    }
    
    // Fetch the team's month schedule
    func fetchTeamMonthSchedule(teamID: Int, season: Int, month: Int, completion: @escaping (Bool) -> Void) {
        NetworkManager.shared.getTeamMonthSchedule(teamID: teamID, season: season, month: month).subscribe(onSuccess: { [weak self] scheduleData in
            guard let self = self else {
                completion(false)
                return
            }
            
            self.scheduleGames = scheduleData.schedules
            completion(true)
        }, onFailure: { error in
            print("Failed to fetch schedule: \(error)")
            completion(false)
        })
        .disposed(by: disposeBag)
    }
    
    // Fetch the team's matchup on the selected day
    func fetchTeamDaySchedule(teamID: Int, date: String, completion: @escaping (Bool) -> Void) {
        NetworkManager.shared.getTeamDaySchedule(teamID: teamID, date: date).subscribe(onSuccess: { [weak self] scheduleData in
            guard let self = self else {
                completion(false)
                return
            }
            
            self.matchupGame = scheduleData.schedules.first
            completion(true)
        }, onFailure: { error in
            print("Failed to fetch schedule: \(error)")
            completion(false)
        })
        .disposed(by: disposeBag)
    }
    
    // Fetch the team's simulation record
    func fetchTeamStats(simulationID: Int, teamID: Int, opponentID: Int?) -> Void {
        NetworkManager.shared.getSimTeamStats(simulationID: simulationID, teamID: teamID).subscribe(onSuccess: { [weak self] simTeamData in
            guard let self = self else { return }
                
            self.simTeamStat = simTeamData
        }, onFailure: { error in
            print("Failed to fetch simulation team stats: \(error)")
        })
        .disposed(by: disposeBag)
        
        if let opponentID = opponentID {
            NetworkManager.shared.getSimTeamStats(simulationID: simulationID, teamID: opponentID).subscribe(onSuccess: { [weak self] simOpponentData in
                guard let self = self else { return }
                    
                self.simOpponentStat = simOpponentData
            }, onFailure: { error in
                print("Failed to fetch simulation team stats: \(error)")
            })
            .disposed(by: disposeBag)
        }
    }
    
    // Text of opponent matchups on the calendar
    func opponentText(date: Date, formatter: DateFormatter, teamID: Int) -> String? {
        let dateString = formatter.string(from: date)
        
        guard let dateGame = scheduleGames.first(where: { $0.date == dateString }) else {
            return nil
        }
        
        return dateGame.awayTeamID == teamID ? (Symbols.atSymbol.rawValue + " " + dateGame.homeTeamAbbrev) : (Symbols.versus.rawValue + " " + dateGame.awayTeamAbbrev)
    }
    
    func teamRecord(teamStat: SimulationTeamStat?) -> String {
        guard let stat = teamStat else {
            return ""
        }
        
        let record = "\(stat.wins)-\(stat.losses)-\(stat.otLosses)"
        return record
    }
}
