//
//  SimulationGoalieStatsService.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-07-05.
//

import Foundation
import RxSwift

public protocol SimulationGoalieStatsService {
    func getSimTeamGoalieStats(simulationID: Int, playerIDs: [Int], teamID: Int) -> Single<SimulationGoalieStatsData>
}

extension NetworkManager: SimulationGoalieStatsService {
    public func getSimTeamGoalieStats(simulationID: Int, playerIDs: [Int], teamID: Int) -> Single<SimulationGoalieStatsData> {
        let parameter: ParameterType = .object(["simulationID": simulationID, "playerIDs": playerIDs, "teamID": teamID])
        let endpoint = Endpoint(method: .get, info: NetworkEndpoint.simulationTeamGoalieStats, parameters: parameter, resultType: SimulationGoalieStatsData.self)
        return networkTask(endpoint: endpoint)
    }
}
