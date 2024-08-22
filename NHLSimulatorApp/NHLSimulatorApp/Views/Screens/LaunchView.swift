//
//  LaunchView.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-05-28.
//

import SwiftUI

struct LaunchView: View {
    @StateObject private var userInfo: UserInfo = UserInfo()
    @StateObject private var simulationState: SimulationState = SimulationState()
    @State private var showUserSetupView: Bool = false
    @State private var showMainView: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                // NHL Logo
                Image(Icon.nhlLogo)
                
                // Title
                Text(LocalizedText.nhlSimulator.localizedString)
                    .appTextStyle()
                    .font(.largeTitle)
                    .padding(.bottom, Spacing.spacingMedium)
                
                // Start button
                Button(action: {
                    simulationState.isNewSim = true
                    if userInfo.isFirstLaunch {
                        showUserSetupView = true
                    } else {
                        showMainView = true
                    }
                }, label: {
                    Text(LocalizedText.newSim.localizedString)
                        .appTextStyle()
                        .font(.headline)
                        .frame(width: 200, height: 75)
                        .appButtonStyle()
                })
                .padding(Spacing.spacingSmall)
                
                // Load button, only exists if not the first launch
                if !userInfo.isFirstLaunch {
                    Button(action: {
                        simulationState.isNewSim = false
                        showMainView = true
                    }, label: {
                        Text(LocalizedText.lastSim.localizedString)
                            .appTextStyle()
                            .font(.headline)
                            .frame(maxWidth: 200, maxHeight: 75)
                            .appButtonStyle()
                    })
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .appBackgroundStyle()
            .navigationDestination(isPresented: $showUserSetupView, destination: {
                // Navigate to User Setup page when Start is clicked and it is the user's first launch
                UserSetupView()
                    .environmentObject(userInfo)
                    .environmentObject(simulationState)
                    .navigationBarHidden(true)
            })
            .navigationDestination(isPresented: $showMainView, destination: {
                // Navigate to Main Sim page when Start is clicked and it is not the user's first launch
                MainSimView()
                    .environmentObject(userInfo)
                    .environmentObject(simulationState)
                    .navigationBarHidden(true)
            })
        }
    }
}
