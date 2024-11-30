//
//  UserViewModel.swift
//  Ebuddy-Test
//
//  Created by Muhammad Rizki Ardyan on 30/11/24.
//

import SwiftUI
import FirebaseFirestore
import FirebaseStorage

fileprivate let collectionName = "USERS"

@Observable final class UserService {
    var users: [UserJSON] = []
    
    var isLoading = false
    
    static let shared = UserService()
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    private init() {}
    
    func fetchUsers() {
        Task {
            isLoading = true
            defer {
                isLoading = false
            }
            
            users = await getUsers()
        }
    }
    
    func fetchUser(id: String) async -> UserJSON? {
        await withCheckedContinuation { continuation in
            db.collection("USERS").whereField("uid", isEqualTo: id).getDocuments { snapshot, error in
                guard let document = snapshot?.documents.first else {
                    continuation.resume(returning: nil)
                    return
                }
                let users = try? document.data(as: UserJSON.self)
                continuation.resume(returning: users)
            }
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
                    try await uploadAvatar(image: image, for: userId)
                    fetchUsers()
                } catch {
                    print("Error", error)
                }
                
                continuation.yield(false)
                continuation.finish()
            }
        }
    }

    private func getUsers() async -> [UserJSON] {
        await withCheckedContinuation { continuation in
            db.collection(collectionName).getDocuments { snapshot, error in
                if error != nil {
                    continuation.resume(returning: [])
                } else if let snapshot = snapshot {
                    let users = snapshot.documents.compactMap { document -> UserJSON? in
                        try? document.data(as: UserJSON.self)
                    }
                    continuation.resume(returning: users)
                }
            }
        }
    }
    
    private func uploadAvatar(image: UIImage, for uid: String) async throws {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else { return }
        let storageRef = storage.reference().child("profileImages/\(uid).jpg")
        
        let _ = try await storageRef.putDataAsync(imageData)
        let url = try await storageRef.downloadURL()
        
        try await updateUserAvatarURL(url, for: uid)
    }
    
    private func updateUserAvatarURL(_ url: URL, for uid: String) async throws {
        let snapshot = try await db.collection("USERS").whereField("uid", isEqualTo: uid).getDocuments()
        guard let document = snapshot.documents.first else {
            return
        }
    
        try await document.reference.updateData(["avatar": url.absoluteString])
        
        if let updatedUser = users.first(where: { $0.uid == uid}) {
            var updatedUser = updatedUser
            updatedUser.avatar = url.absoluteString
            updateUser(updatedUser: updatedUser)
        }
    }
    
    private func updateUser(updatedUser: UserJSON) {
        if let index = users.firstIndex(where: { $0.uid == updatedUser.uid }) {
            users[index] = updatedUser
        }
    }

}
