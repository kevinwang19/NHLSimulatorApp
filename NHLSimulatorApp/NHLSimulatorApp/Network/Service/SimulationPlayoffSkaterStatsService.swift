//
//  SimulationPlayoffSkaterStatsService.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-08-14.
//

import Foundation
import RxSwift

public protocol SimulationPlayoffSkaterStatsService {
    func getSimTeamSkaterPlayoffStats(simulationID: Int, playerIDs: [Int], teamID: Int) -> Single<SimulationPlayoffSkaterStatsData>
    func getSimTeamPositionSkaterPlayoffStats(simulationID: Int, playerIDs: [Int], teamID: Int, position: [String]) -> Single<SimulationPlayoffSkaterStatsData>
}

extension NetworkManager: SimulationPlayoffSkaterStatsService {
    public func getSimTeamSkaterPlayoffStats(simulationID: Int, playerIDs: [Int], teamID: Int) -> Single<SimulationPlayoffSkaterStatsData> {
        let parameter: ParameterType = .object(["simulationID": simulationID, "playerIDs": playerIDs, "teamID": teamID])
        let endpoint = Endpoint(method: .get, info: NetworkEndpoint.simulationTeamSkaterPlayoffStats, parameters: parameter, resultType: SimulationPlayoffSkaterStatsData.self)
        return networkTask(endpoint: endpoint)
    }
    
    public func getSimTeamPositionSkaterPlayoffStats(simulationID: Int, playerIDs: [Int], teamID: Int, position: [String]) -> Single<SimulationPlayoffSkaterStatsData> {
        let parameter: ParameterType = .object(["simulationID": simulationID, "playerIDs": playerIDs, "teamID": teamID, "position": position])
        let endpoint = Endpoint(method: .get, info: NetworkEndpoint.simulationTeamPositionSkaterPlayoffStats, parameters: parameter, resultType: SimulationPlayoffSkaterStatsData.self)
        return networkTask(endpoint: endpoint)
    }
}
