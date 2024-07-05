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
    func getUserData(userID: Int) -> Single<UserData>
}

extension NetworkManager: UsersService {
    public func createUser(username: String, favTeamID: Int) -> Single<UserData> {
        let parameter: ParameterType = .object(["username": username, "fav_team_id": favTeamID])
        let endpoint = Endpoint(method: .post, info: NetworkEndpoint.users, parameters: parameter, resultType: UserData.self)
        return networkTask(endpoint: endpoint)
    }
    
    public func getUserData(userID: Int) -> Single<UserData> {
        let parameter: ParameterType = .object(["user_id": userID])
        let endpoint = Endpoint(method: .get, info: NetworkEndpoint.users, parameters: parameter, resultType: UserData.self)
        return networkTask(endpoint: endpoint)
    }
}

