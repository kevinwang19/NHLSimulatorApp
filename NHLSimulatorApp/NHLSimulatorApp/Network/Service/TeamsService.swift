//
//  TeamsService.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-07-04.
//

import Foundation
import RxSwift

public protocol TeamsService {
    func getTeamData(teamID: Int) -> Single<TeamData>
}

extension NetworkManager: TeamsService {
    public func getTeamData(teamID: Int) -> Single<TeamData> {
        let parameter: ParameterType = .object(["team_id": teamID])
        let endpoint = Endpoint(method: .get, info: NetworkEndpoint.teams, parameters: parameter, resultType: TeamData.self)
        return networkTask(endpoint: endpoint)
    }
}
