//
//  SimulationService.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-07-04.
//

import Foundation
import RxSwift

public protocol SimulationsService {
    func createSimulation(userID: Int) -> Single<SimulationData>
    func updateSimulation(simulationID: Int, simulateDate: String) -> Single<SimulationData>
    func finishSimulation(simulationID: Int) -> Single<SimulationData>
    func getRecentSimulation(userID: Int) -> Single<SimulationData>
}

extension NetworkManager: SimulationsService {
    public func createSimulation(userID: Int) -> Single<SimulationData> {
        let parameter: ParameterType = .object(["userID": userID])
        let endpoint = Endpoint(method: .post, info: NetworkEndpoint.simulations, parameters: parameter, resultType: SimulationData.self)
        return networkTask(endpoint: endpoint)
    }
    
    public func updateSimulation(simulationID: Int, simulateDate: String) -> Single<SimulationData> {
        let parameter: ParameterType = .object(["simulationID": simulationID, "simulateDate": simulateDate])
        let endpoint = Endpoint(method: .put, info: NetworkEndpoint.simulate, parameters: parameter, resultType: SimulationData.self)
        return networkTask(endpoint: endpoint)
    }
    
    public func finishSimulation(simulationID: Int) -> Single<SimulationData> {
        let parameter: ParameterType = .object(["simulationID": simulationID])
        let endpoint = Endpoint(method: .put, info: NetworkEndpoint.finishSimulation, parameters: parameter, resultType: SimulationData.self)
        return networkTask(endpoint: endpoint)
    }
    
    public func getRecentSimulation(userID: Int) -> Single<SimulationData> {
        let parameter: ParameterType = .object(["userID": userID])
        let endpoint = Endpoint(method: .get, info: NetworkEndpoint.userRecentSimulation, parameters: parameter, resultType: SimulationData.self)
        return networkTask(endpoint: endpoint)
    }
}
