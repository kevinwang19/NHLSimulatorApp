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
    @State private var returnToLaunchView: Bool = false
    @State private var backButtonDisabled: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                // Title and back button
                ScreenHeaderView(returnToPreviousView: $returnToLaunchView, backButtonDisabled: $backButtonDisabled)
                
                Spacer()
                
                VStack {
                    // Username title
                    Text(LocalizedText.username.localizedString)
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
                    Text(LocalizedText.favoriteTeam.localizedString)
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
                        
                        Spacer()
                        
                        // Favorite team logo
                        if viewModel.teams.indices.contains(selectedTeamIndex) {
                            let url = URL(string: viewModel.teams[selectedTeamIndex].logo)
                            
                            WebImage(url: url)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 100)
                        } else {
                            Rectangle()
                                .fill(.clear)
                                .scaledToFit()
                                .frame(height: 100)
                        }
                    }
                }
                .frame(maxWidth: 300, alignment: .leading)
                
                Spacer()
                
                // Start button, save info to UserDefaults and save user when tapped, ensure username exists
                if viewModel.usernameText == "" {
                    Button(LocalizedText.start.localizedString) {
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
                            userGenerated in
                            showMainView = userGenerated
                        }
                    }, label: {
                        Text(LocalizedText.start.localizedString)
                            .appTextStyle()
                            .font(.headline)
                            .frame(maxWidth: 200, maxHeight: 75)
                            .appButtonStyle()
                            .padding(.top, Spacing.spacingExtraLarge)
                    })
                }
                
                Spacer()
            }
            .padding(.horizontal, Spacing.spacingExtraSmall)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .appBackgroundStyle()
            .onAppear {
                isTextFieldFocused = true
                viewModel.fetchTeams()
            }
            .ignoresSafeArea(.keyboard)
            .navigationDestination(isPresented: $showMainView, destination: {
                // Navigate to Main Sim page when Start is clicked
                MainSimView()
                    .environmentObject(userInfo)
                    .environmentObject(simulationState)
                    .navigationBarHidden(true)
            })
            .navigationDestination(isPresented: $returnToLaunchView, destination: {
                // Navigate to Launch page when it's button is clicked
                LaunchView()
                    .navigationBarHidden(true)
            })
        }
    }
}
