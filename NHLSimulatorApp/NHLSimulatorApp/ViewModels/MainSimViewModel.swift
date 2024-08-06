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
    @Published var teams: [Team] = []
    @Published var simulationCurrentDate: String?
    @Published var season: Int?
    @Published var scheduleGames: [Schedule] = []
    @Published var matchupGame: Schedule?
    @Published var simTeamStat: SimulationTeamStat?
    @Published var simOpponentStat: SimulationTeamStat?
    @Published var simScores: [SimulationGameStat] = []
    private let disposeBag = DisposeBag()
    private var players: [Player] = []
    private var lineups: [Lineup] = []
    
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
    
    // Fetch and save all players and lineups data
    func setupCoreData(completion: @escaping (Bool) -> Void) {
        CoreDataManager.shared.resetPlayersCoreData()
        CoreDataManager.shared.resetLineupsCoreData()
            
        let dispatchGroup = DispatchGroup()
        var fetchedPlayers: [Player]?
        var fetchedLineups: [Lineup]?
        var fetchError: Error?
            
        dispatchGroup.enter()
        NetworkManager.shared.getAllPlayers().subscribe(onSuccess: { playerData in
            fetchedPlayers = playerData.players
            dispatchGroup.leave()
        }, onFailure: { error in
            print("Failed to fetch players: \(error)")
            fetchError = error
            dispatchGroup.leave()
        })
        .disposed(by: disposeBag)
            
        dispatchGroup.enter()
        NetworkManager.shared.getAllLineups().subscribe(onSuccess: { lineupData in
            fetchedLineups = lineupData.lineups
            dispatchGroup.leave()
        }, onFailure: { error in
            print("Failed to fetch lineups: \(error)")
            fetchError = error
            dispatchGroup.leave()
        })
        .disposed(by: disposeBag)
            
        dispatchGroup.notify(queue: .main) {
            if let error = fetchError {
                print("Error occurred during fetching: \(error)")
                completion(false)
                return
            }
            
            if let players = fetchedPlayers, let lineups = fetchedLineups {
                CoreDataManager.shared.savePlayersCoreData(playerData: players)
                CoreDataManager.shared.saveLineupCoreData(lineupData: lineups)
                completion(true)
            } else {
                completion(false)
            }
        }
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
    func fetchTeamStats(simulationID: Int, teamID: Int, opponentID: Int?, completion: @escaping (Bool) -> Void) {
        NetworkManager.shared.getSimTeamStats(simulationID: simulationID, teamID: teamID).subscribe(onSuccess: { [weak self] simTeamData in
            guard let self = self else {
                completion(false)
                return
            }
                
            self.simTeamStat = simTeamData
        }, onFailure: { error in
            print("Failed to fetch simulation team stats: \(error)")
            completion(false)
        })
        .disposed(by: disposeBag)
        
        if let opponentID = opponentID {
            NetworkManager.shared.getSimTeamStats(simulationID: simulationID, teamID: opponentID).subscribe(onSuccess: { [weak self] simOpponentData in
                guard let self = self else {
                    completion(false)
                    return
                }
                    
                self.simOpponentStat = simOpponentData
                completion(true)
            }, onFailure: { error in
                print("Failed to fetch simulation team stats: \(error)")
                completion(false)
            })
            .disposed(by: disposeBag)
        } else {
            completion(true)
        }
    }
    
    // Simulate up to a certain date
    func simulate(simulationID: Int, simulateDate: String, completion: @escaping (Bool) -> Void) {
        let playersAndLineups = CoreDataManager.shared.fetchPlayersAndLineupsCoreData()
        
        let jsonData: [String: Any] = [
            "simulationID": simulationID,
            "simulateDate": simulateDate,
            "playersAndLineups": playersAndLineups
        ]
        
        do {
            let data = try JSONSerialization.data(withJSONObject: jsonData, options: .prettyPrinted)
            
            NetworkManager.shared.updateSimulation(simulateData: data).subscribe(onSuccess: { [weak self] simulationData in
                guard let self = self else {
                    completion(false)
                    return
                }
                
                self.simulationCurrentDate = simulationData.simulationCurrentDate
                completion(true)
            }, onFailure: { error in
                print("Failed to simulate: \(error)")
                completion(false)
            })
            .disposed(by: disposeBag)
        } catch {
            print("Failed to get data: \(error)")
            completion(false)
        }
    }
    
    // Fetch the scores that have been simmed
    func fetchTeamMatchupScores(simulationID: Int, currentDate: String, teamID: Int, season: Int, completion: @escaping (Bool) -> Void) {
        NetworkManager.shared.getTeamGameStats(simulationID: simulationID, currentDate: currentDate, teamID: teamID, season: season).subscribe(onSuccess: { [weak self] simGameData in
            guard let self = self else {
                completion(false)
                return
            }
            
            self.simScores = simGameData.gameStats
            completion(true)
        }, onFailure: { error in
            print("Failed to fetch simulation game stats: \(error)")
            completion(false)
        })
        .disposed(by: disposeBag)
    }
    
    // Text of opponent matchups on the calendar
    func opponentText(date: Date, teamID: Int) -> String? {
        let dateString = dateFormatter.string(from: date)
        
        guard let dateGame = scheduleGames.first(where: { $0.date == dateString }) else {
            return nil
        }
        
        return dateGame.awayTeamID == teamID ? (Symbols.atSymbol.rawValue + " " + dateGame.homeTeamAbbrev) : (Symbols.versus.rawValue + " " + dateGame.awayTeamAbbrev)
    }
    
    // Text of matchup scores on the calendar
    func scoreText(date: Date, teamID: Int) -> String? {
        let dateString = dateFormatter.string(from: date)
        
        guard let dateGame = scheduleGames.first(where: { $0.date == dateString }) else {
            return nil
        }
        
        guard let dateScore = simScores.first(where: { $0.scheduleID == dateGame.scheduleID }) else {
            return nil
        }
        
        if dateScore.awayTeamID == teamID {
            if dateScore.awayTeamScore > dateScore.homeTeamScore {
                return Symbols.win.rawValue + " " + String(dateScore.awayTeamScore) + Symbols.dashSymbol.rawValue + String(dateScore.homeTeamScore)
            } else {
                return Symbols.loss.rawValue + " " + String(dateScore.awayTeamScore) + Symbols.dashSymbol.rawValue + String(dateScore.homeTeamScore)
            }
        } else {
            if dateScore.awayTeamScore > dateScore.homeTeamScore {
                return Symbols.loss.rawValue + " " + String(dateScore.homeTeamScore) + Symbols.dashSymbol.rawValue + String(dateScore.awayTeamScore)
            } else {
                return Symbols.win.rawValue + " " + String(dateScore.homeTeamScore) + Symbols.dashSymbol.rawValue + String(dateScore.awayTeamScore)
            }
        }
    }
    
    func teamTitle(date: Date, teamID: Int, teamAbbrev: String) -> String {
        let dateString = dateFormatter.string(from: date)
            
        guard let dateGame = scheduleGames.first(where: { $0.date == dateString }) else {
            return teamAbbrev
        }
            
        guard let dateScore = simScores.first(where: { $0.scheduleID == dateGame.scheduleID }) else {
            return teamAbbrev
        }
        
        return teamAbbrev + Symbols.colonSymbol.rawValue + " " + (dateScore.awayTeamID == teamID ? String(dateScore.awayTeamScore) : String(dateScore.homeTeamScore))
    }
    
    // Wins losses and otlosses of a team
    func teamRecord(teamStat: SimulationTeamStat?) -> String {
        guard let stat = teamStat else {
            return ""
        }
        
        let record = "\(stat.wins)-\(stat.losses)-\(stat.otLosses)"
        return record
    }
}
