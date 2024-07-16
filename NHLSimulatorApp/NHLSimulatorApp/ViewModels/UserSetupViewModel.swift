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
            usernameErrorMessage = NSLocalizedString("username_character_error", comment: "")
            isUpdatingText = false
            return
        }
        
        // If filtered string exceeds maximum length, show invalid length error message
        if filtered.count > usernameMaxLength {
            usernameText = String(filtered.prefix(usernameMaxLength))
            usernameErrorMessage = NSLocalizedString("username_length_error", comment: "")
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
}
