//
//  PlayersService.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-07-04.
//

import Foundation
import RxSwift

public protocol PlayersService {
    func getPlayerData(playerID: Int) -> Single<Player>
    func getTeamRoster(teamID: Int) -> Single<PlayerData>
}

extension NetworkManager: PlayersService {
    public func getPlayerData(playerID: Int) -> Single<Player> {
        let parameter: ParameterType = .object(["player_id": playerID])
        let endpoint = Endpoint(method: .get, info: NetworkEndpoint.players, parameters: parameter, resultType: Player.self)
        return networkTask(endpoint: endpoint)
    }
    
    public func getTeamRoster(teamID: Int) -> Single<PlayerData> {
        let parameter: ParameterType = .object(["team_id": teamID])
        let endpoint = Endpoint(method: .get, info: NetworkEndpoint.teamPlayers, parameters: parameter, resultType: PlayerData.self)
        return networkTask(endpoint: endpoint)
    }
}
