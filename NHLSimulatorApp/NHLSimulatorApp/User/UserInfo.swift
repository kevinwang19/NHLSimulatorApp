//
//  UserSettings.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-07-09.
//

import Foundation

class UserInfo: ObservableObject {
    // Update UserDefault changes immediately
    @Published var isFirstLaunch: Bool {
        didSet {
            UserDefaultsManager.setDefaults(key: UserDefaultName.isFirstLaunch.rawValue, value: isFirstLaunch)
        }
    }
    @Published var userID: Int {
        didSet {
            UserDefaultsManager.setDefaults(key: UserDefaultName.userID.rawValue, value: userID)
        }
    }
    @Published var favTeamIndex: Int {
        didSet {
            UserDefaultsManager.setDefaults(key: UserDefaultName.favTeamIndex.rawValue, value: favTeamIndex)
        }
    }
    @Published var simulationID: Int {
        didSet {
            UserDefaultsManager.setDefaults(key: UserDefaultName.simulationID.rawValue, value: simulationID)
        }
    }
    @Published var season: Int {
        didSet {
            UserDefaultsManager.setDefaults(key: UserDefaultName.season.rawValue, value: season)
        }
    }
    @Published var isPlayoffs: Bool {
        didSet {
            UserDefaultsManager.setDefaults(key: UserDefaultName.isPlayoffs.rawValue, value: isPlayoffs)
        }
    }
    @Published var playoffRound1Complete: Bool {
        didSet {
            UserDefaultsManager.setDefaults(key: UserDefaultName.playoffRound1Complete.rawValue, value: playoffRound1Complete)
        }
    }
    @Published var playoffRound2Complete: Bool {
        didSet {
            UserDefaultsManager.setDefaults(key: UserDefaultName.playoffRound2Complete.rawValue, value: playoffRound2Complete)
        }
    }
    @Published var playoffRound3Complete: Bool {
        didSet {
            UserDefaultsManager.setDefaults(key: UserDefaultName.playoffRound3Complete.rawValue, value: playoffRound3Complete)
        }
    }
    @Published var seasonComplete: Bool {
        didSet {
            UserDefaultsManager.setDefaults(key: UserDefaultName.seasonComplete.rawValue, value: seasonComplete)
        }
    }
    
    init() {
        // Check if isFirstLaunch key exists in UserDefaults to see if it is the first app launch and either set or retrive the UserDefault
        if UserDefaults.standard.object(forKey: UserDefaultName.isFirstLaunch.rawValue) == nil {
            isFirstLaunch = true
        } else {
            isFirstLaunch = UserDefaultsManager.getBoolDefaults(key: UserDefaultName.isFirstLaunch.rawValue)
        }
        
        userID = UserDefaultsManager.getIntDefaults(key: UserDefaultName.userID.rawValue)
        favTeamIndex = UserDefaultsManager.getIntDefaults(key: UserDefaultName.favTeamIndex.rawValue)
        simulationID = UserDefaultsManager.getIntDefaults(key: UserDefaultName.simulationID.rawValue)
        season = UserDefaultsManager.getIntDefaults(key: UserDefaultName.season.rawValue)
        isPlayoffs = UserDefaultsManager.getBoolDefaults(key: UserDefaultName.isPlayoffs.rawValue)
        playoffRound1Complete = UserDefaultsManager.getBoolDefaults(key: UserDefaultName.playoffRound1Complete.rawValue)
        playoffRound2Complete = UserDefaultsManager.getBoolDefaults(key: UserDefaultName.playoffRound2Complete.rawValue)
        playoffRound3Complete = UserDefaultsManager.getBoolDefaults(key: UserDefaultName.playoffRound3Complete.rawValue)
        seasonComplete = UserDefaultsManager.getBoolDefaults(key: UserDefaultName.seasonComplete.rawValue)
    }
    
    // Set launch information in UserDefaults
    func setFirstLaunchToFalse() {
        self.isFirstLaunch = false
    }
    
    // Set user setup information in UserDefaults
    func setUserStartInfo(userID: Int, favTeamIndex: Int) {
        self.userID = userID
        self.favTeamIndex = favTeamIndex
    }
    
    // Set simulation setup information in UserDefaults
    func setSimulationStartInfo(simulationID: Int, season: Int) {
        self.simulationID = simulationID
        self.season = season
    }
    
    // Reset playoff info to false in UserDefaults
    func resetPlayoffsInfo() {
        self.isPlayoffs = false
        self.playoffRound1Complete = false
        self.playoffRound2Complete = false
        self.playoffRound3Complete = false
        self.seasonComplete = false
    }
}
