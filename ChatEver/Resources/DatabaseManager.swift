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
        var emailCorrector = email.replacingOccurrences(of: ".", with: "-")
        emailCorrector = emailCorrector.replacingOccurrences(of: "@", with: "-")
        
        database.child(emailCorrector).observeSingleEvent(of: .value, with: { snapshot in
            guard (snapshot.value as? String) != nil else {
                completion(false)
                return
            }
            completion(true)
        })
    }
    
    /// Insert new user to database
    public func insertUser(with user: ChatEverUser) {
        database.child(user.emailCorrector).setValue([
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
    
    var emailCorrector: String {
        var emailCorrector = email.replacingOccurrences(of: ".", with: "-")
        emailCorrector = emailCorrector.replacingOccurrences(of: "@", with: "-")
        return emailCorrector
    }
}
