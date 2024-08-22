//
//  NHLSimulatorAppApp.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-05-28.
//

import SwiftUI
import SDWebImageSVGCoder
import UIKit

@main
struct NHLSimulatorApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        setUpDependencies()
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                LaunchView()
                    .navigationBarHidden(true)
                    .onAppear {
                        // Lock orientation when the view appears
                        let scenes = UIApplication.shared.connectedScenes
                        if let windowScene = scenes.first as? UIWindowScene {
                            let geometryPreferences = UIWindowScene.GeometryPreferences.iOS(interfaceOrientations: .portrait)
                            windowScene.requestGeometryUpdate(geometryPreferences)
                        }
                    }
            }
        }
    }
}

private extension NHLSimulatorApp {
    func setUpDependencies() {
        SDImageCodersManager.shared.addCoder(SDImageSVGCoder.shared)
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
        
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .portrait
    }
}
