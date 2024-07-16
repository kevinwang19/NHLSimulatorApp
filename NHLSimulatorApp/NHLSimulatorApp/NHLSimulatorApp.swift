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
            NavigationView {
                LaunchView()
                    .navigationBarHidden(true)
            }
        }
    }
}

private extension NHLSimulatorApp {
    func setUpDependencies() {
        SDImageCodersManager.shared.addCoder(SDImageSVGCoder.shared)
    }
}
