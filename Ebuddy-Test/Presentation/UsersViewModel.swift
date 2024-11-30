//
//  UsersViewModel.swift
//  Ebuddy-Test
//
//  Created by Muhammad Rizki Ardyan on 30/11/24.
//

import SwiftUI

@Observable final class UsersViewModel {
    var users: [UserJSON] = []
    
    var isLoading = false
    
    private let service = UserService()
    
    init() {
        fetchUsers()
    }
    
    func fetchUsers() {
        Task {
            isLoading = true
            defer {
                isLoading = false
            }
            
            users = await service.getUsers()
        }
    }
}
