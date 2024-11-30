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
    
    func uploadAvatar(image: UIImage, for user: UserJSON) {
        Task {
            guard let userId = user.uid else { return }
            isLoading = true
            defer {
                isLoading = false
            }
            
            do {
                try await service.uploadAvatar(image: image, for: userId)
                fetchUsers()
            } catch {
                print("Error", error)
            }
        }
    }
}
