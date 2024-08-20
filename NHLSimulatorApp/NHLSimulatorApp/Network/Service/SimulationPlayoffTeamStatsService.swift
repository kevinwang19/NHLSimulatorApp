//
//  SimulationPlayoffTeamStatsService.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-08-14.
//

import Foundation
import RxSwift

public protocol SimulationPlayoffTeamStatsService {
    func getSimPlayoffTeamStats(simulationID: Int, teamID: Int) -> Single<SimulationPlayoffTeamStat>
    func getSimAllPlayoffTeamStats(simulationID: Int) -> Single<SimulationPlayoffTeamStatsData>
    func getSimConferencePlayoffTeamStats(simulationID: Int, conference: [String]) -> Single<SimulationPlayoffTeamStatsData>
}

extension NetworkManager: SimulationPlayoffTeamStatsService {
    public func getSimPlayoffTeamStats(simulationID: Int, teamID: Int) -> Single<SimulationPlayoffTeamStat> {
        let parameter: ParameterType = .object(["simulationID": simulationID, "teamID": teamID])
        let endpoint = Endpoint(method: .get, info: NetworkEndpoint.playoffTeamSimulatedStats, parameters: parameter, resultType: SimulationPlayoffTeamStat.self)
        return networkTask(endpoint: endpoint)
    }
    
    public func getSimAllPlayoffTeamStats(simulationID: Int) -> Single<SimulationPlayoffTeamStatsData> {
        let parameter: ParameterType = .object(["simulationID": simulationID])
        let endpoint = Endpoint(method: .get, info: NetworkEndpoint.allPlayoffTeamsSimulatedStats, parameters: parameter, resultType: SimulationPlayoffTeamStatsData.self)
        return networkTask(endpoint: endpoint) 
    }
    
    public func getSimConferencePlayoffTeamStats(simulationID: Int, conference: [String]) -> Single<SimulationPlayoffTeamStatsData> {
        let parameter: ParameterType = .object(["simulationID": simulationID, "conference": conference])
        let endpoint = Endpoint(method: .get, info: NetworkEndpoint.conferencePlayoffTeamsSimulatedStats, parameters: parameter, resultType: SimulationPlayoffTeamStatsData.self)
        return networkTask(endpoint: endpoint)
    }
}
