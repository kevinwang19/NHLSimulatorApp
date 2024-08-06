//
//  SimulationSkaterStatsService.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-07-05.
//

import Foundation
import RxSwift

public protocol SimulationSkaterStatsService {
    func getSimIndividualSkaterStats(simulationID: Int, playerID: Int) -> Single<SimulationSkaterStatsData>
    func getSimTeamSkaterStats(simulationID: Int, teamID: Int) -> Single<SimulationSkaterStatsData>
    func getSimTeamPositionSkaterStats(simulationID: Int, teamID: Int, position: [String]) -> Single<SimulationSkaterStatsData>
}

extension NetworkManager: SimulationSkaterStatsService {
    
    public func getSimIndividualSkaterStats(simulationID: Int, playerID: Int) -> Single<SimulationSkaterStatsData> {
        let parameter: ParameterType = .object(["simulationID": simulationID, "playerID": playerID])
        let endpoint = Endpoint(method: .get, info: NetworkEndpoint.simulationIndividualSkaterStats, parameters: parameter, resultType: SimulationSkaterStatsData.self)
        return networkTask(endpoint: endpoint)
    }
    
    public func getSimTeamSkaterStats(simulationID: Int, teamID: Int) -> Single<SimulationSkaterStatsData> {
        let parameter: ParameterType = .object(["simulationID": simulationID, "teamID": teamID])
        let endpoint = Endpoint(method: .get, info: NetworkEndpoint.simulationTeamSkaterStats, parameters: parameter, resultType: SimulationSkaterStatsData.self)
        return networkTask(endpoint: endpoint)
    }
    
    public func getSimTeamPositionSkaterStats(simulationID: Int, teamID: Int, position: [String]) -> Single<SimulationSkaterStatsData> {
        let parameter: ParameterType = .object(["simulationID": simulationID, "teamID": teamID, "position": position])
        let endpoint = Endpoint(method: .get, info: NetworkEndpoint.simulationTeamPositionSkaterStats, parameters: parameter, resultType: SimulationSkaterStatsData.self)
        return networkTask(endpoint: endpoint)
    }
}
