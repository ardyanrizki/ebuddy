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
    
    func uploadAvatar(image: UIImage, for user: UserJSON) -> AsyncStream<Bool> {
        AsyncStream { continuation in
            Task {
                guard let userId = user.uid else {
                    continuation.finish()
                    return
                }
                
                continuation.yield(true)
                
                do {
                    try await service.uploadAvatar(image: image, for: userId)
                    fetchUsers()
                } catch {
                    print("Error", error)
                }
                
                continuation.yield(false)
                continuation.finish()
            }
        }
    }
}
