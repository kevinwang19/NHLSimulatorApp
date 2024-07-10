//
//  UserDefaultsManager.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-07-09.
//

import Foundation

class UserDefaultsManager {
    class func getStringDefaults(key: String) -> String {
        UserDefaults.standard.string(forKey: key) ?? ""
    }
    
    class func getIntDefaults(key: String) -> Int {
        UserDefaults.standard.integer(forKey: key)
    }
    
    class func getBoolDefaults(key: String) -> Bool {
        UserDefaults.standard.bool(forKey: key)
    }
    
    class func getAnyDefaults(key: String) -> Any? {
        UserDefaults.standard.object(forKey: key)
    }
    
    class func setDefaults(key: String, value: Any?) {
        UserDefaults.standard.set(value, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    class func removeDefaults(key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
