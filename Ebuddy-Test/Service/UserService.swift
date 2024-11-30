//
//  UserViewModel.swift
//  Ebuddy-Test
//
//  Created by Muhammad Rizki Ardyan on 30/11/24.
//

import SwiftUI
import FirebaseFirestore

fileprivate let collectionName = "USERS"

struct UserService {
    private var db = Firestore.firestore()

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
}
