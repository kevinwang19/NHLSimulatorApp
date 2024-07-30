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
    @EnvironmentObject var simulationState: SimulationState
    @ObservedObject var viewModel: UserSetupViewModel = UserSetupViewModel()
    @FocusState private var isTextFieldFocused: Bool
    @State private var selectedTeamIndex: Int = 0
    @State private var showMainView: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                // Title
                Text(LocalizedStringKey(LocalizedText.nhlSimulator.rawValue))
                    .appTextStyle()
                    .font(.title)
                    .padding(Spacing.spacingSmall)
                
                Spacer()
                
                VStack {
                    // Username title
                    Text(LocalizedStringKey(LocalizedText.username.rawValue))
                        .appTextStyle()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Username text field, validates the entry on change
                    TextField("", text: $viewModel.usernameText)
                        .appTextStyle()
                        .padding(Spacing.spacingSmall)
                        .foregroundColor(Color.white)
                        .appButtonStyle()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .focused($isTextFieldFocused)
                        .onChange(of: viewModel.usernameText) { input in viewModel.validateUsername(input: input)
                        }
                    
                    // Username error message
                    Text(viewModel.usernameErrorMessage.isEmpty ? " " : viewModel.usernameErrorMessage)
                        .font(.body)
                        .foregroundColor(Color.red.opacity(0.9))
                        .frame(maxWidth: .infinity)
                    
                    // Favorite team title
                    Text(LocalizedStringKey(LocalizedText.favoriteTeam.rawValue))
                        .appTextStyle()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, Spacing.spacingMedium)
                    
                    HStack {
                        // Favorite team picker
                        Picker(selection: $selectedTeamIndex, label: Text(ElementLabel.teams.rawValue)) {
                            ForEach(viewModel.teams.indices, id: \.self) { index in
                                Text(viewModel.teams[index].fullName)
                                    .appTextStyle()
                                    .font(.headline)
                                    .foregroundColor(Color.white)
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
                        } else {
                            Rectangle()
                                .fill(.clear)
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                        }
                    }
                }
                .frame(maxWidth: 300, alignment: .leading)
                
                Spacer()
                
                // Start button, save info to UserDefaults and save user when tapped, ensure username exists
                if viewModel.usernameText == "" {
                    Button(LocalizedStringKey(LocalizedText.start.rawValue)) {
                        viewModel.emptyUsername()
                    }
                    .appTextStyle()
                    .font(.headline)
                    .frame(maxWidth: 200, maxHeight: 75)
                    .appButtonStyle()
                    .padding(.top, Spacing.spacingExtraLarge)
                } else {
                    Button(action: {
                        userInfo.setFirstLaunchToFalse()
                        
                        viewModel.generateUser(userInfo: userInfo, username: viewModel.usernameText, favTeamID: viewModel.teams[selectedTeamIndex].teamID, favTeamIndex: selectedTeamIndex) {
                            success in
                            showMainView = success
                        }
                    }, label: {
                        Text(LocalizedStringKey(LocalizedText.start.rawValue))
                            .appTextStyle()
                            .font(.headline)
                            .frame(maxWidth: 200, maxHeight: 75)
                            .appButtonStyle()
                            .padding(.top, Spacing.spacingExtraLarge)
                    })
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .appBackgroundStyle()
            .onAppear {
                isTextFieldFocused = true
                viewModel.fetchTeams()
            }
            .navigationDestination(isPresented: $showMainView, destination: {
                // Navigate to Main Sim page when Start is clicked
                MainSimView()
                    .environmentObject(userInfo)
                    .environmentObject(simulationState)
                    .navigationBarHidden(true)
            })
            .ignoresSafeArea(.keyboard)
        }
    }
}

struct UserSetupView_Previews: PreviewProvider {
    static var previews: some View {
        UserSetupView().environmentObject(UserInfo())
    }
}
