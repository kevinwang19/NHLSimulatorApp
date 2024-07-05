//
//  SimulationsData.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-07-04.
//

import Foundation

public struct SimulationData: Codable {
    public let simulationID: Int
    public let userID: Int
    public let season: Int
    public let status: String
    public let simulationCurrentDate: String
}
