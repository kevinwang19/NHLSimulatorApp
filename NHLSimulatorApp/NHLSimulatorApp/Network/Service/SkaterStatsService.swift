//
//  PlayerStatsService.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-07-04.
//

import Foundation
import RxSwift

public protocol SkaterStatsService {
    func getSkaterSeasonStats(playerID: Int, season: Int) -> Single<SkaterStatsData>
    func getSkaterCareerStats(playerID: Int) -> Single<SkaterStatsData>
    func getSkaterPredictedStats(playerID: Int) -> Single<SkaterStatsData>
}

extension NetworkManager: SkaterStatsService {
    public func getSkaterSeasonStats(playerID: Int, season: Int) -> Single<SkaterStatsData> {
        let parameter: ParameterType = .object(["player_id": playerID, "season": season])
        let endpoint = Endpoint(method: .get, info: NetworkEndpoint.skaterSeasonStats, parameters: parameter, resultType: SkaterStatsData.self)
        return networkTask(endpoint: endpoint)
    }
    
    public func getSkaterCareerStats(playerID: Int) -> Single<SkaterStatsData> {
        let parameter: ParameterType = .object(["player_id": playerID])
        let endpoint = Endpoint(method: .get, info: NetworkEndpoint.skaterCareerStats, parameters: parameter, resultType: SkaterStatsData.self)
        return networkTask(endpoint: endpoint)
    }
    
    public func getSkaterPredictedStats(playerID: Int) -> Single<SkaterStatsData> {
        let parameter: ParameterType = .object(["player_id": playerID])
        let endpoint = Endpoint(method: .get, info: NetworkEndpoint.skaterStatsPredictions, parameters: parameter, resultType: SkaterStatsData.self)
        return networkTask(endpoint: endpoint)
    }
}
