//
//  UserSetupView.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-07-10.
//

import SDWebImageSwiftUI
import SwiftUI

struct UserSetupView: View {
    @EnvironmentObject var userInfo: UserInfo
    @ObservedObject var viewModel: UserSetupViewModel
    @FocusState private var isTextFieldFocused: Bool
    @State private var selectedTeamIndex = 0
    
    var body: some View {
        VStack {
            // Title
            Text(LocalizedStringKey("nhl_simulator"))
                .appTextStyle()
                .font(.title)
                .padding(Spacing.spacingSmall.rawValue)
            
            Spacer()
            
            VStack {
                // Username title
                Text(LocalizedStringKey("username"))
                    .appTextStyle()
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Username text field, validates the entry on change
                TextField("", text: $viewModel.usernameText)
                    .appTextStyle()
                    .padding(Spacing.spacingSmall.rawValue)
                    .foregroundColor(.white)
                    .appButtonStyle()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .focused($isTextFieldFocused)
                    .onChange(of: viewModel.usernameText) { input in viewModel.validateUsername(input: input)
                    }
                
                // Username error message
                Text(viewModel.usernameErrorMessage.isEmpty ? " " : viewModel.usernameErrorMessage)
                    .font(.body)
                    .foregroundColor(.red.opacity(0.9))
                    .frame(maxWidth: .infinity)
                
                // Favorite team title
                Text(LocalizedStringKey("favorite_team"))
                    .appTextStyle()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, Spacing.spacingMedium.rawValue)
                
                HStack {
                    // Favorite team picker
                    Picker(selection: $selectedTeamIndex, label: Text("Teams")) {
                        ForEach(viewModel.teams.indices, id: \.self) { index in
                            Text(viewModel.teams[index].fullName)
                                .appTextStyle()
                                .font(.headline)
                                .foregroundColor(.white)
                                .tag(index)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .labelsHidden()
                    .appButtonStyle()
                    .frame(width: 200, height: 100)
                    
                    // Favorite team logo
                    if viewModel.teams.indices.contains(selectedTeamIndex) {
                        let url = URL(string: viewModel.teams[selectedTeamIndex].logo)
                        WebImage(url: url)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                    }
                    else {
                        Rectangle()
                            .fill(.clear)
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                    }
                }
            }
            .frame(maxWidth: 300, alignment: .leading)
            
            Spacer()
            
            // Start button, save info to UserDefaults when tapped
            NavigationLink(destination: SimulationView()) {
                Text(LocalizedStringKey("start"))
                    .appTextStyle()
                    .font(.headline)
                    .frame(maxWidth: 200, maxHeight: 75)
                    .appButtonStyle()
                    .padding(.top, Spacing.spacingExtraLarge.rawValue)
            }
            .simultaneousGesture(TapGesture().onEnded {
                userInfo.setUserStartInfo(username: viewModel.usernameText, favTeamID: viewModel.teams[selectedTeamIndex].teamID)
            })
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .appBackgroundStyle()
        .onAppear {
            isTextFieldFocused = true
            viewModel.fetchTeams()
        }
        .ignoresSafeArea(.keyboard)
    }
}

struct UserSetupView_Previews: PreviewProvider {
    static var previews: some View {
        UserSetupView(viewModel: UserSetupViewModel()).environmentObject(UserInfo())
    }
}
