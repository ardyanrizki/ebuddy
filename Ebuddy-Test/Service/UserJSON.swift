//
//  User.swift
//  Ebuddy-Test
//
//  Created by Muhammad Rizki Ardyan on 30/11/24.
//

import Foundation

struct UserJSON: Identifiable, Codable {
    var id: String
    var uid: String?
    var email: String?
    var phoneNumber: String?
    var gender: GenderEnum?
    
    // Coding keys to match potential Firebase/Firestore naming
    enum CodingKeys: String, CodingKey {
        case uid
        case email
        case phone
        case ge
    }
    
    // Initializer
    init(
        uid: String? = nil,
        email: String? = nil,
        phoneNumber: String? = nil,
        gender: GenderEnum? = nil
    ) {
        self.id = UUID().uuidString
        self.uid = uid
        self.email = email
        self.phoneNumber = phoneNumber
        self.gender = gender
    }
    
    // Custom decoder to handle potential Firestore quirks
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        uid = try container.decodeIfPresent(String.self, forKey: .uid)
        email = try container.decodeIfPresent(String.self, forKey: .email)
        phoneNumber = try container.decodeIfPresent(String.self, forKey: .phone)
        gender = try container.decodeIfPresent(GenderEnum.self, forKey: .ge)
        
        id = UUID().uuidString
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(uid, forKey: .uid)
        try container.encode(email, forKey: .email)
        try container.encode(phoneNumber, forKey: .phone)
        try container.encode(gender, forKey: .ge)
    }
}

// Extension for easy Firebase/Firestore conversion
extension UserJSON {
    var dictionary: [String: Any] {
        var dict: [String: Any] = [:]
        
        if let uid = uid { dict["uid"] = uid }
        if let email = email { dict["email"] = email }
        if let phoneNumber = phoneNumber { dict["phone"] = phoneNumber }
        if let gender = gender { dict["ge"] = gender.rawValue }
        
        return dict
    }
    
    init?(dictionary: [String: Any]) {
        guard let uid = dictionary["uid"] as? String else { return nil }
        
        self.init(
            uid: uid,
            email: dictionary["email"] as? String,
            phoneNumber: dictionary["phone"] as? String,
            gender: (dictionary["ge"] as? Int).flatMap { GenderEnum(rawValue: $0) }
        )
    }
}

// Enum for Gender
enum GenderEnum: Int, Codable {
    case female = 0
    case male = 1
    
    var stringValue: String {
        switch self {
        case .female: return "female"
        case .male: return "male"
        }
    }
}
