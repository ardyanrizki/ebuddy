//
//  UserDetailsViewModel.swift
//  Ebuddy-Test
//
//  Created by Muhammad Rizki Ardyan on 30/11/24.
//

import SwiftUI

@Observable final class UserDetailsViewModel {
    var user: UserJSON? = nil
    
    var isLoading = false
    
    private let userId: String
    private let service = UserService()
    
    init(userId: String) {
        self.userId = userId
        fetchUser()
    }
    
    func fetchUser() {
        Task {
            isLoading = true
            defer {
                isLoading = false
            }
            
            user = await service.getUser(id: userId)
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
                    fetchUser()
                } catch {
                    print("Error", error)
                }
                
                continuation.yield(false)
                continuation.finish()
            }
        }
    }
}
