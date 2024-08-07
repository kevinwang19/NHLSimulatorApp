//
//  SimulationTeamStatsService.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-07-09.
//

import Foundation
import RxSwift

public protocol SimulationTeamStatsService {
    func getSimTeamStats(simulationID: Int, teamID: Int) -> Single<SimulationTeamStat>
    func getSimAllTeamStats(simulationID: Int) -> Single<SimulationTeamStatsData>
    func getSimConferenceTeamStats(simulationID: Int, conference: [String]) -> Single<SimulationTeamStatsData>
    func getSimDivisionTeamStats(simulationID: Int, division: [String]) -> Single<SimulationTeamStatsData>
}

extension NetworkManager: SimulationTeamStatsService {
    public func getSimTeamStats(simulationID: Int, teamID: Int) -> Single<SimulationTeamStat> {
        let parameter: ParameterType = .object(["simulationID": simulationID, "teamID": teamID])
        let endpoint = Endpoint(method: .get, info: NetworkEndpoint.teamSimulatedStats, parameters: parameter, resultType: SimulationTeamStat.self)
        return networkTask(endpoint: endpoint)
    }
    
    public func getSimAllTeamStats(simulationID: Int) -> Single<SimulationTeamStatsData> {
        let parameter: ParameterType = .object(["simulationID": simulationID])
        let endpoint = Endpoint(method: .get, info: NetworkEndpoint.allTeamsSimulatedStats, parameters: parameter, resultType: SimulationTeamStatsData.self)
        return networkTask(endpoint: endpoint)
    }
    
    public func getSimConferenceTeamStats(simulationID: Int, conference: [String]) -> Single<SimulationTeamStatsData> {
        let parameter: ParameterType = .object(["simulationID": simulationID, "conference": conference])
        let endpoint = Endpoint(method: .get, info: NetworkEndpoint.conferenceTeamsSimulatedStats, parameters: parameter, resultType: SimulationTeamStatsData.self)
        return networkTask(endpoint: endpoint)
    }
    
    public func getSimDivisionTeamStats(simulationID: Int, division: [String]) -> Single<SimulationTeamStatsData> {
        let parameter: ParameterType = .object(["simulationID": simulationID, "division": division])
        let endpoint = Endpoint(method: .get, info: NetworkEndpoint.divisionTeamsSimulatedStats, parameters: parameter, resultType: SimulationTeamStatsData.self)
        return networkTask(endpoint: endpoint)
    }
}
