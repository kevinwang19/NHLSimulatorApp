//
//  TeamsService.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-07-04.
//

import Foundation
import RxSwift

public protocol TeamsService {
    func getAllTeams() -> Single<TeamData>
    func getTeamData(teamID: Int) -> Single<Team>
}

extension NetworkManager: TeamsService {
    public func getAllTeams() -> Single<TeamData> {
        let endpoint = Endpoint(method: .get, info: NetworkEndpoint.teams, parameters: nil, resultType: TeamData.self)
        return networkTask(endpoint: endpoint)
    }
    
    public func getTeamData(teamID: Int) -> Single<Team> {
        let parameter: ParameterType = .object(["teamID": teamID])
        let endpoint = Endpoint(method: .get, info: NetworkEndpoint.teams, parameters: parameter, resultType: Team.self)
        return networkTask(endpoint: endpoint)
    }
}
