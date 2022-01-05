//
//  DatabaseManager.swift
//  ChatEver
//
//  Created by administrator on 05/01/2022.
//

import Foundation
import FirebaseDatabase

final class DatabaseManager {
    
    static let shared = DatabaseManager()
    private let database = Database.database().reference()
}

// MARK: - Extentions
// account managment
extension DatabaseManager {
    
    public func validateUserExistence(with email: String, completion: @escaping ((Bool) -> Void)) {
        var correctEmail = email.replacingOccurrences(of: ".", with: "-")
        correctEmail = correctEmail.replacingOccurrences(of: "@", with: "-")
        
        database.child(correctEmail).observeSingleEvent(of: .value, with: { snapshot in
            guard (snapshot.value as? String) != nil else {
                completion(false)
                return
            }
            completion(true)
        })
    }
    
    /// Insert new user to database
    public func insertUser(with user: ChatEverUser) {
        database.child(user.correctEmail).setValue([
            "firstName": user.firstName,
            "lastName": user.lastName
        ])
    }
}

struct ChatEverUser {
    //let profilePic: URL //string
    let firstName: String
    let lastName: String
    let email: String
    
    var correctEmail: String {
        var correctEmail = email.replacingOccurrences(of: ".", with: "-")
        correctEmail = correctEmail.replacingOccurrences(of: "@", with: "-")
        return correctEmail
    }
}
