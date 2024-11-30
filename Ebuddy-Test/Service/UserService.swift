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

struct UserService {
    private let db = Firestore.firestore()
    private let storage = Storage.storage()

    func getUsers() async -> [UserJSON] {
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
    
    func getUser(id: String) async -> UserJSON? {
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
    
    func uploadAvatar(image: UIImage, for uid: String) async throws {
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
    }
}
