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
    static func emailCorrector(email: String) -> String {
        var emailCorrector = email.replacingOccurrences(of: ".", with: "-")
        emailCorrector = emailCorrector.replacingOccurrences(of: "@", with: "-")
        return emailCorrector
    }
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
    
    // Database form
    /*
     users [
      [
        "Name": " "
        "Email Address": " "
      ],
     ]
     */
    // save new user
    public func insertUser(with user: ChatEverUser, completion: @escaping (Bool) -> Void) {
        database.child(user.emailCorrector).setValue([
            "firstName": user.firstName,
            "lastName": user.lastName
        ], withCompletionBlock: { [weak self] error, _ in
            guard let strongSelf = self else { return }
            guard error == nil else {
                print("Write to Database Failed")
                completion(false)
                return
            }
            strongSelf.database.child("users").observeSingleEvent(of: .value, with: { snapshot in
                if var usersCollection = snapshot.value as? [[String: String]] {
                    // append
                    let newUser = [
                        "Name": "\(user.firstName) \(user.lastName)",
                        "Email Address": user.emailCorrector
                    ]
                    usersCollection.append(newUser)
                    strongSelf.database.child("users").setValue(usersCollection, withCompletionBlock: { error, _ in
                        
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        completion(true)
                    })
                } else {
                    // create
                    let newCollection: [[String: String]] = [
                    [
                        "Name": "\(user.firstName) \(user.lastName)",
                        "Email Address": user.emailCorrector
                    ]]
                    strongSelf.database.child("users").setValue(newCollection, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        completion(true)
                    })
                }
            })
        })
    } // end function insertUser
    
    // Get All Users
    public func getAllUsers(completion: @escaping (Result<[[String: String]], Error>) -> Void) {
        database.child("users").observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value as? [[String: String]] else {
                completion(.failure(DatabseErrors.failedToFetch))
                return
            }
            completion(.success(value))
        })
    } // end function getAllUsers
    
    // MARK: - Enums
    public enum DatabseErrors: Error {
        case failedToFetch
    }
} // end extension DatabaseManager

// MARK: - Structs
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
    
    var profilePic: String {
        return "\(emailCorrector)_profile_picture.png"
    }
}
