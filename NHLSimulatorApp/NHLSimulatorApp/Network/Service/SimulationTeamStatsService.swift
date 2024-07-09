//
//  SimulationTeamStatsService.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-07-09.
//

import Foundation
import RxSwift

public protocol SimulationTeamStatsService {
    func initializeSimTeamStats(simulationID: Int) -> Single<SimulationTeamStatsData>
    func getSimTeamStats(simulationID: Int, teamID: Int) -> Single<SimulationTeamStat>
    func getSimAllTeamStats(simulationID: Int) -> Single<SimulationTeamStatsData>
}

extension NetworkManager: SimulationTeamStatsService {
    public func initializeSimTeamStats(simulationID: Int) -> Single<SimulationTeamStatsData> {
        let parameter: ParameterType = .object(["simulation_id": simulationID])
        let endpoint = Endpoint(method: .post, info: NetworkEndpoint.simulationTeamStats, parameters: parameter, resultType: SimulationTeamStatsData.self)
        return networkTask(endpoint: endpoint)
    }
    
    public func getSimTeamStats(simulationID: Int, teamID: Int) -> Single<SimulationTeamStat> {
        let parameter: ParameterType = .object(["simulation_id": simulationID, "team_id": teamID])
        let endpoint = Endpoint(method: .get, info: NetworkEndpoint.teamSimulatedStats, parameters: parameter, resultType: SimulationTeamStat.self)
        return networkTask(endpoint: endpoint)
    }
    
    public func getSimAllTeamStats(simulationID: Int) -> Single<SimulationTeamStatsData> {
        let parameter: ParameterType = .object(["simulation_id": simulationID])
        let endpoint = Endpoint(method: .get, info: NetworkEndpoint.allTeamsSimulatedStats, parameters: parameter, resultType: SimulationTeamStatsData.self)
        return networkTask(endpoint: endpoint)
    }
}
