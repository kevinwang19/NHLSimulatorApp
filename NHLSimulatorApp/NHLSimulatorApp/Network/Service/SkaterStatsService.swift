//
//  PlayerStatsService.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-07-04.
//

import Foundation
import RxSwift

public protocol SkaterStatsService {
    func getSkaterCareerStats(playerID: Int) -> Single<SkaterStatsData>
    func getSkaterPredictedStats(playerID: Int) -> Single<SkaterStatsData>
}

extension NetworkManager: SkaterStatsService {
    public func getSkaterCareerStats(playerID: Int) -> Single<SkaterStatsData> {
        let parameter: ParameterType = .object(["playerID": playerID])
        let endpoint = Endpoint(method: .get, info: NetworkEndpoint.skaterCareerStats, parameters: parameter, resultType: SkaterStatsData.self)
        return networkTask(endpoint: endpoint)
    }
    
    public func getSkaterPredictedStats(playerID: Int) -> Single<SkaterStatsData> {
        let parameter: ParameterType = .object(["playerID": playerID])
        let endpoint = Endpoint(method: .get, info: NetworkEndpoint.skaterPredictedStats, parameters: parameter, resultType: SkaterStatsData.self)
        return networkTask(endpoint: endpoint)
    }
}
