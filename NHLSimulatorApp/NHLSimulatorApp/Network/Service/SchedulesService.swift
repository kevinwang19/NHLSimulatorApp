//
//  SchedulesService.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-07-04.
//

import Foundation
import RxSwift

public protocol SchedulesService {
    func getTeamDaySchedule(teamID: Int, date: String) -> Single<ScheduleData>
    func getTeamMonthSchedule(teamID: Int, season: Int, month: Int) -> Single<ScheduleData>
}

extension NetworkManager: SchedulesService {
    public func getTeamDaySchedule(teamID: Int, date: String) -> Single<ScheduleData> {
        let parameter: ParameterType = .object(["teamID": teamID, "date": date])
        let endpoint = Endpoint(method: .get, info: NetworkEndpoint.teamDaySchedule, parameters: parameter, resultType: ScheduleData.self)
        return networkTask(endpoint: endpoint)
    }
    
    public func getTeamMonthSchedule(teamID: Int, season: Int, month: Int) -> Single<ScheduleData> {
        let parameter: ParameterType = .object(["teamID": teamID, "season": season, "month": month])
        let endpoint = Endpoint(method: .get, info: NetworkEndpoint.teamMonthSchedules, parameters: parameter, resultType: ScheduleData.self)
        return networkTask(endpoint: endpoint)
    }
}
