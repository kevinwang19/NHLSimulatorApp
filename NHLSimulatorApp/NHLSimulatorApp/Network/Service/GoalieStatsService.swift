//
//  GoalieStatsService.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-07-04.
//

import Foundation
import RxSwift

public protocol GoalieStatsService {
    func getGoalieCareerStats(playerID: Int) -> Single<GoalieStatsData>
    func getGoaliePredictedStats(playerID: Int) -> Single<GoalieStatsData>
}

extension NetworkManager: GoalieStatsService {
    public func getGoalieCareerStats(playerID: Int) -> Single<GoalieStatsData> {
        let parameter: ParameterType = .object(["playerID": playerID])
        let endpoint = Endpoint(method: .get, info: NetworkEndpoint.goalieCareerStats, parameters: parameter, resultType: GoalieStatsData.self)
        return networkTask(endpoint: endpoint)
    }
    
    public func getGoaliePredictedStats(playerID: Int) -> Single<GoalieStatsData> {
        let parameter: ParameterType = .object(["playerID": playerID])
        let endpoint = Endpoint(method: .get, info: NetworkEndpoint.goaliePredictedStats, parameters: parameter, resultType: GoalieStatsData.self)
        return networkTask(endpoint: endpoint)
    }
}
