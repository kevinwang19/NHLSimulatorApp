//
//  SimulationGameStatsService.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-07-09.
//

import Foundation
import RxSwift

public protocol SimulationGameStatsService {
    func getSimGameStats(simulationID: Int, scheduleID: Int) -> Single<SimulationGameStat>
    func getSimAllGameStats(simulationID: Int) -> Single<SimulationGameStatsData>
}

extension NetworkManager: SimulationGameStatsService {
    public func getSimGameStats(simulationID: Int, scheduleID: Int) -> Single<SimulationGameStat> {
        let parameter: ParameterType = .object(["simulationID": simulationID, "scheduleID": scheduleID])
        let endpoint = Endpoint(method: .get, info: NetworkEndpoint.gameSimulatedStats, parameters: parameter, resultType: SimulationGameStat.self)
        return networkTask(endpoint: endpoint)
    }
    
    public func getSimAllGameStats(simulationID: Int) -> Single<SimulationGameStatsData> {
        let parameter: ParameterType = .object(["simulationID": simulationID])
        let endpoint = Endpoint(method: .get, info: NetworkEndpoint.allGamesSimulatedStats, parameters: parameter, resultType: SimulationGameStatsData.self)
        return networkTask(endpoint: endpoint)
    }
}
