//
//  UsersService.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-07-04.
//

import Foundation
import RxSwift

public protocol UsersService {
    func createUser(username: String, favTeamID: Int) -> Single<UserData>
}

extension NetworkManager: UsersService {
    public func createUser(username: String, favTeamID: Int) -> Single<UserData> {
        let parameter: ParameterType = .object(["username": username, "favTeamID": favTeamID])
        let endpoint = Endpoint(method: .post, info: NetworkEndpoint.users, parameters: parameter, resultType: UserData.self)
        return networkTask(endpoint: endpoint)
    }
}

