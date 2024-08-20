//
//  TeamStandingsViewModel.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-08-05.
//

import Foundation
import RxSwift
import SwiftUI

class TeamStandingsViewModel: ObservableObject {
    @Published var simTeamStats: [SimulationTeamStat] = []
    private let disposeBag = DisposeBag()
    
    // Fetch league team simulation stats
    func fetchAllTeamSimStats(simulationID: Int, completion: @escaping (Bool) -> Void) {
        NetworkManager.shared.getSimAllTeamStats(simulationID: simulationID).subscribe(onSuccess: { [weak self] simulationTeamStats in
            guard let self = self else {
                completion(false)
                return
            }
            
            self.simTeamStats = simulationTeamStats.teamStats
            completion(true)
        }, onFailure: { error in
            print("Failed to fetch team simulation stats: \(error)")
            completion(false)
        })
        .disposed(by: disposeBag)
    }
    
    // Fetch conference team simulation stats
    func fetchConferenceTeamSimStats(simulationID: Int, conference: String, completion: @escaping (Bool) -> Void) {
        let includedConferences: [String] = {
            switch conference {
            case ConferenceType.all.rawValue:
                return [
                    ConferenceType.eastern.rawValue,
                    ConferenceType.western.rawValue
                ]
            case ConferenceType.eastern.rawValue:
                return [ConferenceType.eastern.rawValue]
            case ConferenceType.western.rawValue:
                return [ConferenceType.western.rawValue]
            default:
                return [
                    ConferenceType.eastern.rawValue,
                    ConferenceType.western.rawValue
                ]
            }
        }()
        
        NetworkManager.shared.getSimConferenceTeamStats(simulationID: simulationID, conference: includedConferences).subscribe(onSuccess: { [weak self] simulationTeamStats in
            guard let self = self else {
                completion(false)
                return
            }
            
            self.simTeamStats = simulationTeamStats.teamStats
            completion(true)
        }, onFailure: { error in
            print("Failed to fetch team simulation stats: \(error)")
            completion(false)
        })
        .disposed(by: disposeBag)
    }
    
    // Fetch division team simulation stats
    func fetchDivisionTeamSimStats(simulationID: Int, conference: String, division: String, completion: @escaping (Bool) -> Void) {
        let includedDivisions: [String] = {
            if conference == ConferenceType.eastern.rawValue {
                switch division {
                case EastDivisionType.all.rawValue:
                    return [EastDivisionType.atlantic.rawValue, EastDivisionType.metropolitan.rawValue]
                case EastDivisionType.atlantic.rawValue:
                    return [EastDivisionType.atlantic.rawValue]
                case EastDivisionType.metropolitan.rawValue:
                    return [EastDivisionType.metropolitan.rawValue]
                default:
                    return [EastDivisionType.atlantic.rawValue, EastDivisionType.metropolitan.rawValue]
                }
            } else {
                switch division {
                case WestDivisionType.all.rawValue:
                    return [WestDivisionType.central.rawValue, WestDivisionType.pacific.rawValue]
                case WestDivisionType.central.rawValue:
                    return [WestDivisionType.central.rawValue]
                case WestDivisionType.pacific.rawValue:
                    return [WestDivisionType.pacific.rawValue]
                default:
                    return [WestDivisionType.central.rawValue, WestDivisionType.pacific.rawValue]
                }
            }
        }()
        
        NetworkManager.shared.getSimDivisionTeamStats(simulationID: simulationID, division: includedDivisions).subscribe(onSuccess: { [weak self] simulationTeamStats in
            guard let self = self else {
                completion(false)
                return
            }
            
            self.simTeamStats = simulationTeamStats.teamStats
            completion(true)
        }, onFailure: { error in
            print("Failed to fetch team simulation stats: \(error)")
            completion(false)
        })
        .disposed(by: disposeBag)
    }
}
