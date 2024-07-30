//
//  GoalieStatsService.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-07-04.
//

import Foundation
import RxSwift

public protocol GoalieStatsService {
    func getGoalieSeasonStats(playerID: Int, season: Int) -> Single<GoalieStatsData>
    func getGoalieCareerStats(playerID: Int) -> Single<GoalieStatsData>
    func getGoaliePredictedStats(playerID: Int) -> Single<GoalieStatsData>
}

extension NetworkManager: GoalieStatsService {
    public func getGoalieSeasonStats(playerID: Int, season: Int) -> Single<GoalieStatsData> {
        let parameter: ParameterType = .object(["playerID": playerID, "season": season])
        let endpoint = Endpoint(method: .get, info: NetworkEndpoint.goalieSeasonStats, parameters: parameter, resultType: GoalieStatsData.self)
        return networkTask(endpoint: endpoint)
    }
    
    public func getGoalieCareerStats(playerID: Int) -> Single<GoalieStatsData> {
        let parameter: ParameterType = .object(["playerID": playerID])
        let endpoint = Endpoint(method: .get, info: NetworkEndpoint.goalieCareerStats, parameters: parameter, resultType: GoalieStatsData.self)
        return networkTask(endpoint: endpoint)
    }
    
    public func getGoaliePredictedStats(playerID: Int) -> Single<GoalieStatsData> {
        let parameter: ParameterType = .object(["playerID": playerID])
        let endpoint = Endpoint(method: .get, info: NetworkEndpoint.goalieStatsPredictions, parameters: parameter, resultType: GoalieStatsData.self)
        return networkTask(endpoint: endpoint)
    }
}
