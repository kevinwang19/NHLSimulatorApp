//
//  SimulationGoalieStatsService.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-07-05.
//

import Foundation
import RxSwift

public protocol SimulationGoalieStatsService {
    func initializeSimGoalieStats(simulationID: Int) -> Single<SimulationGoalieStatsData>
    func getSimGoalieStats(simulationID: Int, playerID: Int) -> Single<SimulationGoalieStat>
    func getSimAllGoalieStats(simulationID: Int) -> Single<SimulationGoalieStatsData>
}

extension NetworkManager: SimulationGoalieStatsService {
    public func initializeSimGoalieStats(simulationID: Int) -> Single<SimulationGoalieStatsData> {
        let parameter: ParameterType = .object(["simulationID": simulationID])
        let endpoint = Endpoint(method: .post, info: NetworkEndpoint.simulationGoalieStats, parameters: parameter, resultType: SimulationGoalieStatsData.self)
        return networkTask(endpoint: endpoint)
    }
    
    public func getSimGoalieStats(simulationID: Int, playerID: Int) -> Single<SimulationGoalieStat> {
        let parameter: ParameterType = .object(["simulationID": simulationID, "playerID": playerID])
        let endpoint = Endpoint(method: .get, info: NetworkEndpoint.simulationGoalieStats, parameters: parameter, resultType: SimulationGoalieStat.self)
        return networkTask(endpoint: endpoint)
    }
    
    public func getSimAllGoalieStats(simulationID: Int) -> Single<SimulationGoalieStatsData> {
        let parameter: ParameterType = .object(["simulationID": simulationID])
        let endpoint = Endpoint(method: .get, info: NetworkEndpoint.simulationAllGoalieStats, parameters: parameter, resultType: SimulationGoalieStatsData.self)
        return networkTask(endpoint: endpoint)
    }
}
