//
//  SimulationSkaterStatsService.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-07-05.
//

import Foundation
import RxSwift

public protocol SimulationSkaterStatsService {
    func initializeSimSkaterStats(simulationID: Int) -> Single<SimulationSkaterStatsData>
    func getSimSkaterStats(simulationID: Int, playerID: Int) -> Single<SimulationSkaterStat>
    func getSimAllSkaterStats(simulationID: Int) -> Single<SimulationSkaterStatsData>
}

extension NetworkManager: SimulationSkaterStatsService {
    public func initializeSimSkaterStats(simulationID: Int) -> Single<SimulationSkaterStatsData> {
        let parameter: ParameterType = .object(["simulationID": simulationID])
        let endpoint = Endpoint(method: .post, info: NetworkEndpoint.simulationSkaterStats, parameters: parameter, resultType: SimulationSkaterStatsData.self)
        return networkTask(endpoint: endpoint)
    }
    
    public func getSimSkaterStats(simulationID: Int, playerID: Int) -> Single<SimulationSkaterStat> {
        let parameter: ParameterType = .object(["simulationID": simulationID, "playerID": playerID])
        let endpoint = Endpoint(method: .get, info: NetworkEndpoint.simulationSkaterStats, parameters: parameter, resultType: SimulationSkaterStat.self)
        return networkTask(endpoint: endpoint)
    }
    
    public func getSimAllSkaterStats(simulationID: Int) -> Single<SimulationSkaterStatsData> {
        let parameter: ParameterType = .object(["simulationID": simulationID])
        let endpoint = Endpoint(method: .get, info: NetworkEndpoint.simulationAllSkaterStats, parameters: parameter, resultType: SimulationSkaterStatsData.self)
        return networkTask(endpoint: endpoint)
    }
}
