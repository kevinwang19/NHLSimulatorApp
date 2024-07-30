//
//  NHLSimulatorAppApp.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-05-28.
//

import SwiftUI
import SDWebImageSVGCoder

@main
struct NHLSimulatorApp: App {
    init() {
        setUpDependencies()
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                LaunchView()
            }
        }
    }
}

private extension NHLSimulatorApp {
    func setUpDependencies() {
        SDImageCodersManager.shared.addCoder(SDImageSVGCoder.shared)
    }
}
