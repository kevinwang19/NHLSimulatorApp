//
//  Enums.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-07-15.
//

import Foundation

enum AppInfo: String {
    case appModel = "NHLSimulatorAppModel"
    case corePlayer = "CorePlayer"
    case coreLineup = "CoreLineup"
}

enum UserDefaultName: String {
    case isFirstLaunch
    case username
    case favTeamID
}

enum Spacing: CGFloat {
    case spacingSmall = 20.0
    case spacingMedium = 40.0
    case spacingLarge = 60.0
    case spacingExtraLarge = 80.0
}
