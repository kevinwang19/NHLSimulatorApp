//
//  SchedulesService.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-07-04.
//

import Foundation
import RxSwift

public protocol SchedulesService {
    func getScheduleData(scheduleID: Int) -> Single<Schedule>
    func getDateSchedule(date: String) -> Single<ScheduleData>
    func getTeamSeasonSchedule(teamID: Int, season: Int) -> Single<ScheduleData>
    func getTeamMonthSchedule(teamID: Int, season: Int, month: Int) -> Single<ScheduleData>
}

extension NetworkManager: SchedulesService {
    public func getScheduleData(scheduleID: Int) -> Single<Schedule> {
        let parameter: ParameterType = .object(["schedule_id": scheduleID])
        let endpoint = Endpoint(method: .get, info: NetworkEndpoint.schedules, parameters: parameter, resultType: Schedule.self)
        return networkTask(endpoint: endpoint)
    }
    
    public func getDateSchedule(date: String) -> Single<ScheduleData> {
        let parameter: ParameterType = .object(["date": date])
        let endpoint = Endpoint(method: .get, info: NetworkEndpoint.dateSchedules, parameters: parameter, resultType: ScheduleData.self)
        return networkTask(endpoint: endpoint)
    }
    
    public func getTeamSeasonSchedule(teamID: Int, season: Int) -> Single<ScheduleData> {
        let parameter: ParameterType = .object(["team_id": teamID, "season": season])
        let endpoint = Endpoint(method: .get, info: NetworkEndpoint.teamSeasonSchedules, parameters: parameter, resultType: ScheduleData.self)
        return networkTask(endpoint: endpoint)
    }
    
    public func getTeamMonthSchedule(teamID: Int, season: Int, month: Int) -> Single<ScheduleData> {
        let parameter: ParameterType = .object(["team_id": teamID, "season": season, "month": month])
        let endpoint = Endpoint(method: .get, info: NetworkEndpoint.teamMonthSchedules, parameters: parameter, resultType: ScheduleData.self)
        return networkTask(endpoint: endpoint)
    }
}
