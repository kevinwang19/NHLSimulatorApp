//
//  PlayoffSchedulesService.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-08-14.
//

import Foundation
import RxSwift

public protocol PlayoffSchedulesService {
    func createRound1PlayoffSchedule(lineupData: Data) -> Single<PlayoffScheduleData>
    func getlastRound1PlayoffGame(simulationID: Int) -> Single<PlayoffSchedule>
    func createRound2PlayoffSchedule(simulationID: Int) -> Single<PlayoffScheduleData>
    func getlastRound2PlayoffGame(simulationID: Int) -> Single<PlayoffSchedule>
    func createRound3PlayoffSchedule(simulationID: Int) -> Single<PlayoffScheduleData>
    func getlastRound3PlayoffGame(simulationID: Int) -> Single<PlayoffSchedule>
    func createRound4PlayoffSchedule(simulationID: Int) -> Single<PlayoffScheduleData>
    func getlastRound4PlayoffGame(simulationID: Int) -> Single<PlayoffSchedule>
    func deleteExtraPlayoffGames(simulationID: Int, roundNumber: Int) -> Single<PlayoffScheduleData>
    func getTeamDayPlayoffSchedule(simulationID: Int, teamID: Int, date: String) -> Single<PlayoffScheduleData>
    func getTeamMonthPlayoffSchedule(simulationID: Int, teamID: Int, month: Int) -> Single<PlayoffScheduleData>
    func getTeamPlayoffGameStats(simulationID: Int, currentDate: String, teamID: Int) -> Single<PlayoffScheduleData>
}

extension NetworkManager: PlayoffSchedulesService {
    public func createRound1PlayoffSchedule(lineupData: Data) -> Single<PlayoffScheduleData> {
        let parameter: ParameterType = .data(lineupData)
        let endpoint = Endpoint(method: .post, info: NetworkEndpoint.createRound1PlayoffSchedules, parameters: parameter, resultType: PlayoffScheduleData.self)
        return networkTask(endpoint: endpoint)
    }
    
    public func getlastRound1PlayoffGame(simulationID: Int) -> Single<PlayoffSchedule> {
        let parameter: ParameterType = .object(["simulationID": simulationID])
        let endpoint = Endpoint(method: .get, info: NetworkEndpoint.lastRound1PlayoffSchedule, parameters: parameter, resultType: PlayoffSchedule.self)
        return networkTask(endpoint: endpoint)
    }
    
    public func createRound2PlayoffSchedule(simulationID: Int) -> Single<PlayoffScheduleData> {
        let parameter: ParameterType = .object(["simulationID": simulationID])
        let endpoint = Endpoint(method: .post, info: NetworkEndpoint.createRound2PlayoffSchedules, parameters: parameter, resultType: PlayoffScheduleData.self)
        return networkTask(endpoint: endpoint)
    }
    
    public func getlastRound2PlayoffGame(simulationID: Int) -> Single<PlayoffSchedule> {
        let parameter: ParameterType = .object(["simulationID": simulationID])
        let endpoint = Endpoint(method: .get, info: NetworkEndpoint.lastRound2PlayoffSchedule, parameters: parameter, resultType: PlayoffSchedule.self)
        return networkTask(endpoint: endpoint)
    }
    
    public func createRound3PlayoffSchedule(simulationID: Int) -> Single<PlayoffScheduleData> {
        let parameter: ParameterType = .object(["simulationID": simulationID])
        let endpoint = Endpoint(method: .post, info: NetworkEndpoint.createRound3PlayoffSchedules, parameters: parameter, resultType: PlayoffScheduleData.self)
        return networkTask(endpoint: endpoint)
    }
    
    public func getlastRound3PlayoffGame(simulationID: Int) -> Single<PlayoffSchedule> {
        let parameter: ParameterType = .object(["simulationID": simulationID])
        let endpoint = Endpoint(method: .get, info: NetworkEndpoint.lastRound3PlayoffSchedule, parameters: parameter, resultType: PlayoffSchedule.self)
        return networkTask(endpoint: endpoint)
    }
    
    public func createRound4PlayoffSchedule(simulationID: Int) -> Single<PlayoffScheduleData> {
        let parameter: ParameterType = .object(["simulationID": simulationID])
        let endpoint = Endpoint(method: .post, info: NetworkEndpoint.createRound4PlayoffSchedules, parameters: parameter, resultType: PlayoffScheduleData.self)
        return networkTask(endpoint: endpoint)
    }
    
    public func getlastRound4PlayoffGame(simulationID: Int) -> Single<PlayoffSchedule> {
        let parameter: ParameterType = .object(["simulationID": simulationID])
        let endpoint = Endpoint(method: .get, info: NetworkEndpoint.lastRound4PlayoffSchedule, parameters: parameter, resultType: PlayoffSchedule.self)
        return networkTask(endpoint: endpoint)
    }
    
    public func deleteExtraPlayoffGames(simulationID: Int, roundNumber: Int) -> Single<PlayoffScheduleData> {
        let parameter: ParameterType = .object(["simulationID": simulationID, "roundNumber": roundNumber])
        let endpoint = Endpoint(method: .delete, info: NetworkEndpoint.deleteExtraPlayoffSchedules, parameters: parameter, resultType: PlayoffScheduleData.self)
        return networkTask(endpoint: endpoint)
    }
    
    public func getTeamDayPlayoffSchedule(simulationID: Int, teamID: Int, date: String) -> Single<PlayoffScheduleData> {
        let parameter: ParameterType = .object(["simulationID": simulationID, "teamID": teamID, "date": date])
        let endpoint = Endpoint(method: .get, info: NetworkEndpoint.teamDayPlayoffSchedule, parameters: parameter, resultType: PlayoffScheduleData.self)
        return networkTask(endpoint: endpoint)
    }
    
    public func getTeamMonthPlayoffSchedule(simulationID: Int, teamID: Int, month: Int) -> Single<PlayoffScheduleData> {
        let parameter: ParameterType = .object(["simulationID": simulationID, "teamID": teamID, "month": month])
        let endpoint = Endpoint(method: .get, info: NetworkEndpoint.teamMonthPlayoffSchedules, parameters: parameter, resultType: PlayoffScheduleData.self)
        return networkTask(endpoint: endpoint)
    }
    
    public func getTeamPlayoffGameStats(simulationID: Int, currentDate: String, teamID: Int) -> Single<PlayoffScheduleData> {
        let parameter: ParameterType = .object(["simulationID": simulationID, "currentDate": currentDate, "teamID": teamID])
        let endpoint = Endpoint(method: .get, info: NetworkEndpoint.teamSimulatedPlayoffGameStats, parameters: parameter, resultType: PlayoffScheduleData.self)
        return networkTask(endpoint: endpoint)
    }
}
