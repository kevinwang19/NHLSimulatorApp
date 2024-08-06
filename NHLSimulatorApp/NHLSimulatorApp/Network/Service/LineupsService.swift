//
//  LineupsService.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-07-05.
//

import Foundation
import RxSwift

public protocol LineupsService {
    func getAllLineups() -> Single<LineupData>
}

extension NetworkManager: LineupsService {
    public func getAllLineups() -> Single<LineupData> {
        let endpoint = Endpoint(method: .get, info: NetworkEndpoint.lineups, parameters: nil, resultType: LineupData.self)
        return networkTask(endpoint: endpoint)
    }
}
