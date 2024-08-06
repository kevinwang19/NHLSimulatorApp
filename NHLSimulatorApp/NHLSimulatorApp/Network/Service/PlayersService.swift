//
//  PlayersService.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-07-04.
//

import Foundation
import RxSwift

public protocol PlayersService {
    func getAllPlayers() -> Single<PlayerData>
}

extension NetworkManager: PlayersService {
    public func getAllPlayers() -> Single<PlayerData> {
        let endpoint = Endpoint(method: .get, info: NetworkEndpoint.players, parameters: nil, resultType: PlayerData.self)
        return networkTask(endpoint: endpoint)
    }
}
