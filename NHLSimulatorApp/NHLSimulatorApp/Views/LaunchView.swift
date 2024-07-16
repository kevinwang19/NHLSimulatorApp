//
//  ContentView.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-05-28.
//

import SwiftUI

struct LaunchView: View {
    @StateObject private var userInfo = UserInfo()
    
    var body: some View {
        VStack {
            // Title
            Text(LocalizedStringKey("nhl_simulator"))
                .appTextStyle()
                .font(.largeTitle)
                .padding(Spacing.spacingMedium.rawValue)
            
            // Start button
            NavigationLink(destination:
                Group {
                    // Navigate to user setup view if it is the first launch otherwise jump straight into a new sim
                    if userInfo.isFirstLaunch {
                        UserSetupView(viewModel: UserSetupViewModel())
                            .environmentObject(userInfo)
                            .navigationBarHidden(true)
                    } else {
                        SimulationView()
                            .environmentObject(userInfo)
                            .navigationBarHidden(true)
                    }
                }
            ) {
                Text(LocalizedStringKey("new_sim"))
                    .appTextStyle()
                    .font(.headline)
                    .frame(maxWidth: 200, maxHeight: 75)
                    .appButtonStyle()
            }
            .padding(Spacing.spacingSmall.rawValue)
            
            // Load button, only exists if not the first launch
            if !userInfo.isFirstLaunch {
                NavigationLink(destination: SimulationView().navigationBarHidden(true)) {
                    Text(LocalizedStringKey("last_sim"))
                        .appTextStyle()
                        .font(.headline)
                        .frame(maxWidth: 200, maxHeight: 75)
                        .appButtonStyle()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .appBackgroundStyle()
    }
}

struct LaunchView_Previews: PreviewProvider {
    static var previews: some View {
        LaunchView()
    }
}
