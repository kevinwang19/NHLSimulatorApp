//
//  SimulationPlayoffGoalieStatsService.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-08-14.
//

import Foundation
import RxSwift

public protocol SimulationPlayoffGoalieStatsService {
    func getSimTeamGoaliePlayoffStats(simulationID: Int, playerIDs: [Int], teamID: Int) -> Single<SimulationPlayoffGoalieStatsData>
}

extension NetworkManager: SimulationPlayoffGoalieStatsService {
    public func getSimTeamGoaliePlayoffStats(simulationID: Int, playerIDs: [Int], teamID: Int) -> Single<SimulationPlayoffGoalieStatsData> {
        let parameter: ParameterType = .object(["simulationID": simulationID, "playerIDs": playerIDs, "teamID": teamID])
        let endpoint = Endpoint(method: .get, info: NetworkEndpoint.simulationTeamGoaliePlayoffStats, parameters: parameter, resultType: SimulationPlayoffGoalieStatsData.self)
        return networkTask(endpoint: endpoint)
    }
}
