//
//  SimulationGameStatsService.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-07-09.
//

import Foundation
import RxSwift

public protocol SimulationGameStatsService {
    func getTeamGameStats(simulationID: Int, currentDate: String, teamID: Int, season: Int) -> Single<SimulationGameStatsData>
}

extension NetworkManager: SimulationGameStatsService {
    public func getTeamGameStats(simulationID: Int, currentDate: String, teamID: Int, season: Int) -> Single<SimulationGameStatsData> {
        let parameter: ParameterType = .object(["simulationID": simulationID, "currentDate": currentDate, "teamID": teamID, "season": season])
        let endpoint = Endpoint(method: .get, info: NetworkEndpoint.teamSimulatedGameStats, parameters: parameter, resultType: SimulationGameStatsData.self)
        return networkTask(endpoint: endpoint)
    }
}
