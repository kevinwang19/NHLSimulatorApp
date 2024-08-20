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
    @Published var playoffScheduleGames: [PlayoffSchedule] = []
    @Published var matchupGame: Schedule?
    @Published var playoffMatchupGame: PlayoffSchedule?
    @Published var simTeamStat: SimulationTeamStat?
    @Published var simOpponentStat: SimulationTeamStat?
    @Published var simPlayoffTeamStat: SimulationPlayoffTeamStat?
    @Published var simPlayoffOpponentStat: SimulationPlayoffTeamStat?
    @Published var simScores: [SimulationGameStat] = []
    @Published var playoffSimScores: [PlayoffSchedule] = []
    @Published var lastGameDate: String = ""
    @Published var lastRound1GameDate: String = ""
    @Published var lastRound2GameDate: String = ""
    @Published var lastRound3GameDate: String = ""
    @Published var lastRound4GameDate: String = ""
    @Published var winnerTeamName: String = ""
    @Published var winnerTeamLogo: String = ""
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
    func simulate(simulationID: Int, simulateDate: String, isPlayoffs: Bool, completion: @escaping (Bool) -> Void) {
        let playersAndLineups = CoreDataManager.shared.fetchPlayersAndLineupsCoreData()
        
        let jsonData: [String: Any] = [
            "simulationID": simulationID,
            "simulateDate": simulateDate,
            "playersAndLineups": playersAndLineups,
            "isPlayoffs": isPlayoffs
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
    
    // Fetch the last game of the season
    func fetchLastGame(season: Int, completion: @escaping (Bool) -> Void) {
        NetworkManager.shared.getLastGame(season: season).subscribe(onSuccess: { [weak self] scheduleData in
            guard let self = self else {
                completion(false)
                return
            }
            
            self.lastGameDate = scheduleData.date
            completion(true)
        }, onFailure: { error in
            print("Failed to fetch last game: \(error)")
            completion(false)
        })
        .disposed(by: disposeBag)
    }
    
    // Create round 1 matchups of the playoffs
    func createPlayoffRound1Schedules(simulationID: Int, completion: @escaping (Bool) -> Void) {
        let lineups = CoreDataManager.shared.fetchPlayersAndLineupsCoreData()
        
        let jsonData: [String: Any] = [
            "simulationID": simulationID,
            "lineups": lineups
        ]
        
        do {
            let data = try JSONSerialization.data(withJSONObject: jsonData, options: .prettyPrinted)
            
            NetworkManager.shared.createRound1PlayoffSchedule(lineupData: data).subscribe(onSuccess: { _ in
                completion(true)
            }, onFailure: { error in
                print("Failed to create round 1 playoff schedule: \(error)")
                completion(false)
            })
            .disposed(by: disposeBag)
        } catch {
            print("Failed to get data: \(error)")
            completion(false)
        }
    }
    
    // Fetch the last game of round 1 of the playoffs
    func fetchRound1LastGame(simulationID: Int, completion: @escaping (Bool) -> Void) {
        NetworkManager.shared.getlastRound1PlayoffGame(simulationID: simulationID).subscribe(onSuccess: { [weak self] scheduleData in
            guard let self = self else {
                completion(false)
                return
            }
            
            self.lastRound1GameDate = scheduleData.date
            completion(true)
        }, onFailure: { error in
            print("Failed to fetch playoff round 1 last game: \(error)")
            completion(false)
        })
        .disposed(by: disposeBag)
    }
    
    // Create round 2 matchups of the playoffs
    func createPlayoffRound2Schedules(simulationID: Int, completion: @escaping (Bool) -> Void) {
        NetworkManager.shared.createRound2PlayoffSchedule(simulationID: simulationID).subscribe(onSuccess: { _ in
            completion(true)
        }, onFailure: { error in
            print("Failed to create round 2 playoff schedule: \(error)")
            completion(false)
        })
        .disposed(by: disposeBag)
    }
    
    // Fetch the last game of round 2 of the playoffs
    func fetchRound2LastGame(simulationID: Int, completion: @escaping (Bool) -> Void) {
        NetworkManager.shared.getlastRound2PlayoffGame(simulationID: simulationID).subscribe(onSuccess: { [weak self] scheduleData in
            guard let self = self else {
                completion(false)
                return
            }
            
            self.lastRound2GameDate = scheduleData.date
            completion(true)
        }, onFailure: { error in
            print("Failed to fetch playoff round 2 last game: \(error)")
            completion(false)
        })
        .disposed(by: disposeBag)
    }
    
    // Create round 3 (conference finals) matchups of the playoffs
    func createPlayoffRound3Schedules(simulationID: Int, completion: @escaping (Bool) -> Void) {
        NetworkManager.shared.createRound3PlayoffSchedule(simulationID: simulationID).subscribe(onSuccess: { _ in
            completion(true)
        }, onFailure: { error in
            print("Failed to create round 3 playoff schedule: \(error)")
            completion(false)
        })
        .disposed(by: disposeBag)
    }
    
    // Fetch the last game of round 3 (conference finals) of the playoffs
    func fetchRound3LastGame(simulationID: Int, completion: @escaping (Bool) -> Void) {
        NetworkManager.shared.getlastRound3PlayoffGame(simulationID: simulationID).subscribe(onSuccess: { [weak self] scheduleData in
            guard let self = self else {
                completion(false)
                return
            }
            
            self.lastRound3GameDate = scheduleData.date
            completion(true)
        }, onFailure: { error in
            print("Failed to fetch playoff round 3 last game: \(error)")
            completion(false)
        })
        .disposed(by: disposeBag)
    }
    
    // Create round 4 (Stanley Cup Finals) matchups of the playoffs
    func createPlayoffRound4Schedules(simulationID: Int, completion: @escaping (Bool) -> Void) {
        NetworkManager.shared.createRound4PlayoffSchedule(simulationID: simulationID).subscribe(onSuccess: { _ in
            completion(true)
        }, onFailure: { error in
            print("Failed to create round 4 playoff schedule: \(error)")
            completion(false)
        })
        .disposed(by: disposeBag)
    }
    
    // Fetch the last game of round 4 (Stanley Cup Finals) of the playoffs
    func fetchRound4LastGame(simulationID: Int, completion: @escaping (Bool) -> Void) {
        NetworkManager.shared.getlastRound4PlayoffGame(simulationID: simulationID).subscribe(onSuccess: { [weak self] scheduleData in
            guard let self = self else {
                completion(false)
                return
            }
            
            self.lastRound4GameDate = scheduleData.date
            self.winnerTeamName = scheduleData.awayTeamScore ?? 0 > scheduleData.homeTeamScore ?? 0 ? scheduleData.awayTeamAbbrev : scheduleData.homeTeamAbbrev
            self.winnerTeamLogo = scheduleData.awayTeamScore ?? 0 > scheduleData.homeTeamScore ?? 0 ? scheduleData.awayTeamLogo : scheduleData.homeTeamLogo
            completion(true)
        }, onFailure: { error in
            print("Failed to fetch playoff round 4 last game: \(error)")
            completion(false)
        })
        .disposed(by: disposeBag)
    }
    
    // Fetch the team's playoff month schedule
    func fetchTeamMonthPlayoffSchedule(simulationID: Int, teamID: Int, month: Int, completion: @escaping (Bool) -> Void) {
        NetworkManager.shared.getTeamMonthPlayoffSchedule(simulationID: simulationID, teamID: teamID, month: month).subscribe(onSuccess: { [weak self] playoffScheduleData in
            guard let self = self else {
                completion(false)
                return
            }
            
            self.playoffScheduleGames = playoffScheduleData.playoffSchedules
            completion(true)
        }, onFailure: { error in
            print("Failed to fetch playoff schedule: \(error)")
            completion(false)
        })
        .disposed(by: disposeBag)
    }
    
    // Fetch the team's playoff matchup on the selected day
    func fetchTeamDayPlayoffSchedule(simulationID: Int, teamID: Int, date: String, completion: @escaping (Bool) -> Void) {
        NetworkManager.shared.getTeamDayPlayoffSchedule(simulationID: simulationID, teamID: teamID, date: date).subscribe(onSuccess: { [weak self] playoffScheduleData in
            guard let self = self else {
                completion(false)
                return
            }
            
            self.playoffMatchupGame = playoffScheduleData.playoffSchedules.first
            completion(true)
        }, onFailure: { error in
            print("Failed to fetch playoff schedule: \(error)")
            completion(false)
        })
        .disposed(by: disposeBag)
    }
    
    // Fetch the team's playoff simulation record
    func fetchTeamPlayoffStats(simulationID: Int, teamID: Int, opponentID: Int?, completion: @escaping (Bool) -> Void) {
        NetworkManager.shared.getSimPlayoffTeamStats(simulationID: simulationID, teamID: teamID).subscribe(onSuccess: { [weak self] simPlayoffTeamData in
            guard let self = self else {
                completion(false)
                return
            }
                
            self.simPlayoffTeamStat = simPlayoffTeamData
        }, onFailure: { error in
            print("Failed to fetch simulation playoff team stats: \(error)")
            completion(false)
        })
        .disposed(by: disposeBag)
        
        if let opponentID = opponentID {
            NetworkManager.shared.getSimPlayoffTeamStats(simulationID: simulationID, teamID: opponentID).subscribe(onSuccess: { [weak self] simPlayoffOpponentData in
                guard let self = self else {
                    completion(false)
                    return
                }
                    
                self.simPlayoffOpponentStat = simPlayoffOpponentData
                completion(true)
            }, onFailure: { error in
                print("Failed to fetch simulation playoff team stats: \(error)")
                completion(false)
            })
            .disposed(by: disposeBag)
        } else {
            completion(true)
        }
    }
    
    // Fetch the playoff scores that have been simmed
    func fetchTeamPlayoffMatchupScores(simulationID: Int, currentDate: String, teamID: Int, completion: @escaping (Bool) -> Void) {
        NetworkManager.shared.getTeamPlayoffGameStats(simulationID: simulationID, currentDate: currentDate, teamID: teamID).subscribe(onSuccess: { [weak self] playoffScheduleData in
            guard let self = self else {
                completion(false)
                return
            }
            
            self.playoffSimScores = playoffScheduleData.playoffSchedules
            completion(true)
        }, onFailure: { error in
            print("Failed to fetch simulation playoff game stats: \(error)")
            completion(false)
        })
        .disposed(by: disposeBag)
    }
    
    // Delete playoff games that are no longer required
    func deleteExtraPlayoffSchedules(simulationID: Int, isRound2: Bool, isRound3: Bool, isRound4: Bool, completion: @escaping (Bool) -> Void) {
        let roundNumber = isRound4 ? 4 : (isRound3 ? 3 : (isRound2 ? 2 : 1))
        NetworkManager.shared.deleteExtraPlayoffGames(simulationID: simulationID, roundNumber: roundNumber).subscribe(onSuccess: { _ in
            completion(true)
        }, onFailure: { error in
            print("Failed to delete playoff schedules: \(error)")
            completion(false)
        })
        .disposed(by: disposeBag)
    }
    
    // Update simulation as finished
    func finishSimulation(simulationID: Int, completion: @escaping (Bool) -> Void) {
        NetworkManager.shared.finishSimulation(simulationID: simulationID).subscribe(onSuccess: { _ in
            completion(true)
        }, onFailure: { error in
            print("Failed to finish simulation: \(error)")
            completion(false)
        })
        .disposed(by: disposeBag)
    }
    
    // Text of opponent matchups on the calendar
    func opponentText(date: Date, teamID: Int) -> String? {
        let dateString = dateFormatter.string(from: date)
        
        guard let lastGameDate = dateFormatter.date(from: lastGameDate) else {
            return nil
        }
        
        if date > lastGameDate {
            guard let datePlayoffGame = playoffScheduleGames.first(where: { $0.date == dateString }) else {
                return nil
            }
            
            return datePlayoffGame.awayTeamID == teamID ? (Symbols.atSymbol.rawValue + " " + datePlayoffGame.homeTeamAbbrev) : (Symbols.versus.rawValue + " " + datePlayoffGame.awayTeamAbbrev)
        } else {
            guard let dateGame = scheduleGames.first(where: { $0.date == dateString }) else {
                return nil
            }
            
            return dateGame.awayTeamID == teamID ? (Symbols.atSymbol.rawValue + " " + dateGame.homeTeamAbbrev) : (Symbols.versus.rawValue + " " + dateGame.awayTeamAbbrev)
        }
    }
    
    // Text of matchup scores on the calendar
    func scoreText(date: Date, teamID: Int) -> String? {
        let dateString = dateFormatter.string(from: date)
        
        guard let lastGameDate = dateFormatter.date(from: lastGameDate) else {
            return nil
        }
        
        if date > lastGameDate {
            guard let datePlayoffGame = playoffScheduleGames.first(where: { $0.date == dateString && ($0.awayTeamScore != nil && $0.homeTeamScore != nil) }) else {
                return nil
            }
            
            if datePlayoffGame.awayTeamID == teamID {
                if datePlayoffGame.awayTeamScore ?? 0 > datePlayoffGame.homeTeamScore ?? 0 {
                    return Symbols.win.rawValue + " " + String(datePlayoffGame.awayTeamScore ?? 0) + Symbols.dashSymbol.rawValue + String(datePlayoffGame.homeTeamScore ?? 0)
                } else {
                    return Symbols.loss.rawValue + " " + String(datePlayoffGame.awayTeamScore ?? 0) + Symbols.dashSymbol.rawValue + String(datePlayoffGame.homeTeamScore ?? 0)
                }
            } else {
                if datePlayoffGame.awayTeamScore ?? 0 > datePlayoffGame.homeTeamScore ?? 0 {
                    return Symbols.loss.rawValue + " " + String(datePlayoffGame.homeTeamScore ?? 0) + Symbols.dashSymbol.rawValue + String(datePlayoffGame.awayTeamScore ?? 0)
                } else {
                    return Symbols.win.rawValue + " " + String(datePlayoffGame.homeTeamScore ?? 0) + Symbols.dashSymbol.rawValue + String(datePlayoffGame.awayTeamScore ?? 0)
                }
            }
        } else {
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
    }
    
    // Name and score of a team
    func teamTitle(date: Date, teamID: Int, teamAbbrev: String) -> String {
        let dateString = dateFormatter.string(from: date)
        
        guard let lastGameDate = dateFormatter.date(from: lastGameDate) else {
            return teamAbbrev
        }
        
        if date > lastGameDate {
            guard let datePlayoffGame = playoffScheduleGames.first(where: { $0.date == dateString && ($0.awayTeamScore != nil && $0.homeTeamScore != nil) }) else {
                return teamAbbrev
            }
            
            return teamAbbrev + Symbols.colonSymbol.rawValue + " " + (datePlayoffGame.awayTeamID == teamID ? String(datePlayoffGame.awayTeamScore ?? 0) : String(datePlayoffGame.homeTeamScore ?? 0))
        } else {
            guard let dateGame = scheduleGames.first(where: { $0.date == dateString }) else {
                return teamAbbrev
            }
                
            guard let dateScore = simScores.first(where: { $0.scheduleID == dateGame.scheduleID }) else {
                return teamAbbrev
            }
            
            return teamAbbrev + Symbols.colonSymbol.rawValue + " " + (dateScore.awayTeamID == teamID ? String(dateScore.awayTeamScore) : String(dateScore.homeTeamScore))
        }
    }
    
    // Wins losses and otlosses of a team
    func teamRecord(teamStat: SimulationTeamStat?) -> String {
        guard let stat = teamStat else {
            return ""
        }
        
        let record = "\(stat.wins)-\(stat.losses)-\(stat.otLosses)"
        return record
    }
    
    // Wins and losses of a playoff team
    func teamPlayoffRecord(teamPlayoffStat: SimulationPlayoffTeamStat?) -> String {
        guard let stat = teamPlayoffStat else {
            return ""
        }
        
        if stat.teamID == 0 {
            return "-"
        }
        
        let record = "\(stat.wins)-\(stat.losses + stat.otLosses)"
        return record
    }
}
