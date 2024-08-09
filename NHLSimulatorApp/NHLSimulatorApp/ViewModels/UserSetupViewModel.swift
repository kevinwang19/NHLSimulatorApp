//
//  UserSetupViewModel.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-07-11.
//

import Foundation
import RxSwift
import SwiftUI

class UserSetupViewModel: ObservableObject {
    @Published var teams: [Team] = []
    @Published var usernameText: String = "" {
        // Validate username only when changes are inputted
        didSet {
            if !isUpdatingText {
                validateUsername(input: usernameText)
            }
        }
    }
    @Published var usernameErrorMessage: String = ""
    private let usernameMaxLength = 15
    private var isUpdatingText = false
    private let disposeBag = DisposeBag()
    
    var userID: Int?
    
    // Fetch all teams
    func fetchTeams() {
        NetworkManager.shared.getAllTeams().subscribe(onSuccess: { [weak self] teamData in
            guard let self = self else { return }
                
            self.teams = teamData.teams
        }, onFailure: { error in
            print("Failed to fetch teams: \(error)")
        })
        .disposed(by: disposeBag)
    }
    
    // Ensure valid username
    func validateUsername(input: String) {
        isUpdatingText = true
        // Filter out non-alphanumeric characters
        let filtered = input.filter { $0.isLetter || $0.isNumber }
        
        // If filtered string does not match original input, show invalid character error message
        if input != filtered {
            usernameText = filtered
            usernameErrorMessage = LocalizedText.usernameCharacterError.localizedString
            isUpdatingText = false
            return
        }
        
        // If filtered string exceeds maximum length, show invalid length error message
        if filtered.count > usernameMaxLength {
            usernameText = String(filtered.prefix(usernameMaxLength))
            usernameErrorMessage = LocalizedText.usernameLengthError.localizedString
            isUpdatingText = false
            return
        }
        
        // If filtered string is valid, set it as the username and clear error message
        usernameText = filtered
        if filtered.count <= usernameMaxLength && filtered == input {
            usernameErrorMessage = ""
        }
        
        isUpdatingText = false
    }
    
    // When the username field is empty
    func emptyUsername() {
        usernameErrorMessage = LocalizedText.usernameEmptyError.localizedString
    }
    
    // Create the user and fetch the userID
    func generateUser(userInfo: UserInfo, username: String, favTeamID: Int, favTeamIndex: Int, completion: @escaping (Bool) -> Void) {
        NetworkManager.shared.createUser(username: username, favTeamID: favTeamID).subscribe(onSuccess: { [weak self] userData in
            guard let self = self else {
                completion(false)
                return
            }
                
            self.userID = userData.userID
            userInfo.setUserStartInfo(userID: userData.userID, favTeamIndex: favTeamIndex)
            completion(true)
        }, onFailure: { error in
            print("Failed to generate user: \(error)")
            completion(false)
        })
        .disposed(by: disposeBag)
    }
}
