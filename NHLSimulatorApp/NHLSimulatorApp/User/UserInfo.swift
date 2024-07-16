//
//  UserSettings.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-07-09.
//

import Foundation

class UserInfo: ObservableObject {
    // Track if it's the user's first app launch and update UserDefault on changes
    @Published var isFirstLaunch: Bool {
        didSet {
            UserDefaultsManager.setDefaults(key: UserDefaultName.isFirstLaunch.rawValue, value: isFirstLaunch)
        }
    }
    
    init() {
        // Check if isFirstLaunch key exists in UserDefaults to see if it is the first app launch and either set or retrive the UserDefault
        if UserDefaults.standard.object(forKey: UserDefaultName.isFirstLaunch.rawValue) == nil {
            isFirstLaunch = true
            UserDefaultsManager.setDefaults(key: UserDefaultName.isFirstLaunch.rawValue, value: true)
        } else {
            isFirstLaunch = UserDefaultsManager.getBoolDefaults(key: UserDefaultName.isFirstLaunch.rawValue)
        }
    }
    
    // Set user setup information in UserDefaults
    func setUserStartInfo(username: String, favTeamID: Int) {
        UserDefaultsManager.setDefaults(key: UserDefaultName.username.rawValue, value: username)
        UserDefaultsManager.setDefaults(key: UserDefaultName.favTeamID.rawValue, value: favTeamID)
    }
}
