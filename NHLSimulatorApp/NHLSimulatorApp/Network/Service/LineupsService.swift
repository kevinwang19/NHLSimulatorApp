//
//  LineupsService.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-07-05.
//

import Foundation
import RxSwift

public protocol LineupsService {
    func getLineupData(lineupID: Int) -> Single<Lineup>
    func getPlayerLineup(playerID: Int) -> Single<Lineup>
    func getTeamLineup(teamID: Int) -> Single<LineupData>
}

extension NetworkManager: LineupsService {
    public func getLineupData(lineupID: Int) -> Single<Lineup> {
        let parameter: ParameterType = .object(["lineupID": lineupID])
        let endpoint = Endpoint(method: .get, info: NetworkEndpoint.lineups, parameters: parameter, resultType: Lineup.self)
        return networkTask(endpoint: endpoint)
    }
    
    public func getPlayerLineup(playerID: Int) -> Single<Lineup> {
        let parameter: ParameterType = .object(["playerID": playerID])
        let endpoint = Endpoint(method: .get, info: NetworkEndpoint.playerLineups, parameters: parameter, resultType: Lineup.self)
        return networkTask(endpoint: endpoint)
    }
    
    public func getTeamLineup(teamID: Int) -> Single<LineupData> {
        let parameter: ParameterType = .object(["teamID": teamID])
        let endpoint = Endpoint(method: .get, info: NetworkEndpoint.teamLineups, parameters: parameter, resultType: LineupData.self)
        return networkTask(endpoint: endpoint)
    }
}
