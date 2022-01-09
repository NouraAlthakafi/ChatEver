//
//  DatabaseManager.swift
//  ChatEver
//
//  Created by administrator on 05/01/2022.
//

import Foundation
import FirebaseDatabase
import MessageKit
import CoreLocation

final class DatabaseManager {
    
    /// Shared instance of class
    static let shared = DatabaseManager()
    private let database = Database.database().reference()
    static func emailCorrector(email: String) -> String {
        var emailCorrector = email.replacingOccurrences(of: ".", with: "-")
        emailCorrector = emailCorrector.replacingOccurrences(of: "@", with: "-")
        return emailCorrector
    }
} // end of class DatabaseManager

// MARK: - Extentions
extension DatabaseManager {
    
    /// Returns dictionary node at child path
    public func getDataFor(path: String, completion: @escaping (Result<Any, Error>) -> Void) {
        database.child("\(path)").observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value else {
                completion(.failure(DatabseErrors.failedToFetch))
                return
            }
            completion(.success(value))
        }
    } // end of function getDataFor
    
    // account management
    public func validateUserExistence(with email: String, completion: @escaping ((Bool) -> Void)) {
        let emailCorrector = DatabaseManager.emailCorrector(email: email)
        database.child(emailCorrector).observeSingleEvent(of: .value, with: { snapshot in
            guard snapshot.value as? [String: Any] != nil else {
                completion(false)
                return
            }
            completion(true)
        })
    } // end of function validateUserExistence
    
    /// Inserts new user
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
                        "name": "\(user.firstName) \(user.lastName)",
                        "email": user.emailCorrector
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
                        "name": "\(user.firstName) \(user.lastName)",
                        "email": user.emailCorrector
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
    
    /// Gets all users
    public func getAllUsers(completion: @escaping (Result<[[String: String]], Error>) -> Void) {
        database.child("users").observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value as? [[String: String]] else {
                completion(.failure(DatabseErrors.failedToFetch))
                return
            }
            completion(.success(value))
        })
    } // end function getAllUsers
    
    /// Creates a new conversation with target user email and first message sent
    public func createNewConversation(with friendEmail: String, nameFull: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String,
            let currentName = UserDefaults.standard.value(forKey: "name") as? String else {
                return
        }
        let emailCorrector = DatabaseManager.emailCorrector(email: currentEmail)

        let ref = database.child("\(emailCorrector)")

        ref.observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard var userNode = snapshot.value as? [String: Any] else {
                completion(false)
                print("User not Found")
                return
            }

            let messageDate = firstMessage.sentDate
            let dateString = MessagesVC.dateFormatter.string(from: messageDate)

            var message = ""

            switch firstMessage.kind {
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .custom(_), .linkPreview(_):
                break
            }

            let conversationId = "conversation_\(firstMessage.messageId)"

            let newConversationData: [String: Any] = [
                "id": conversationId,
                "other_user_email": friendEmail,
                "name": nameFull,
                "latest_message": [
                    "date": dateString,
                    "message": message,
                    "is_read": false
                ]
            ]

            let recipient_newConversationData: [String: Any] = [
                "id": conversationId,
                "other_user_email": emailCorrector,
                "name": currentName,
                "latest_message": [
                    "date": dateString,
                    "message": message,
                    "is_read": false
                ]
            ]
            
            // Update recipient conversaiton entry
            self?.database.child("\(friendEmail)/conversations").observeSingleEvent(of: .value, with: { [weak self] snapshot in
                if var conversatoins = snapshot.value as? [[String: Any]] {
                    // append
                    conversatoins.append(recipient_newConversationData)
                    self?.database.child("\(friendEmail)/conversations").setValue(conversatoins)
                } else {
                    // create
                    self?.database.child("\(friendEmail)/conversations").setValue([recipient_newConversationData])
                }
            })

            // Update current user conversation entry
            if var conversations = userNode["conversations"] as? [[String: Any]] {
                
                // conversation array exists for current user > append
                conversations.append(newConversationData)
                userNode["conversations"] = conversations
                ref.setValue(userNode, withCompletionBlock: { [weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    self?.finishCreatingConversation(name: nameFull,
                                                     conversationID: conversationId,
                                                     firstMessage: firstMessage,
                                                     completion: completion)
                })
            } else {
                // conversation array doesn't exist > create
                userNode["conversations"] = [
                    newConversationData
                ]
                
                ref.setValue(userNode, withCompletionBlock: { [weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }

                    self?.finishCreatingConversation(name: nameFull,
                                                     conversationID: conversationId,
                                                     firstMessage: firstMessage,
                                                     completion: completion)
                })
            }
        })
    } // end of function createNewConversation
    
    private func finishCreatingConversation(name: String, conversationID: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
        let messageDate = firstMessage.sentDate
        let dateString = MessagesVC.dateFormatter.string(from: messageDate)
        var message = ""
        switch firstMessage.kind {
        case .text(let messageText):
            message = messageText
        case .attributedText(_), .photo(_), .video(_), .location(_), .emoji(_), .audio(_), .contact(_),.custom(_), .linkPreview(_):
            break
        }

        guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            completion(false)
            return
        }

        let currentUserEmail = DatabaseManager.emailCorrector(email: myEmail)

        let collectionMessage: [String: Any] = [
            "id": firstMessage.messageId,
            "type": firstMessage.kind.messageKindString,
            "content": message,
            "date": dateString,
            "sender_email": currentUserEmail,
            "is_read": false,
            "name": name
        ]

        let value: [String: Any] = [
            "messages": [
                collectionMessage
            ]
        ]

        print("Adding Conversation: \(conversationID)")

        database.child("\(conversationID)").setValue(value, withCompletionBlock: { error, _ in
            guard error == nil else {
                completion(false)
                return
            }
            completion(true)
        })
    } // end of function finishCreatingConversation
    
    public func getAllConversations(for email: String, completion: @escaping (Result<[Conversation], Error>) -> Void) {
            database.child("\(email)/conversations").observe(.value, with: { snapshot in
                guard let value = snapshot.value as? [[String: Any]] else{
                    completion(.failure(DatabseErrors.failedToFetch))
                    return
                }
                
                let conversations: [Conversation] = value.compactMap({ dictionary in
                    guard let conversationId = dictionary["id"] as? String,
                          let name = dictionary["name"] as? String,
                          let otherUserEmail = dictionary["other_user_email"] as? String,
                          let latestMessage = dictionary["latest_message"] as? [String: Any],
                          let date = latestMessage["date"] as? String,
                          let message = latestMessage["message"] as? String,
                          let isRead = latestMessage["is_read"] as? Bool else {
                              return nil
                          }
                    
                    let latestMmessageObject = LatestMessage(date: date,
                                                             text: message,
                                                             isRead: isRead)
                    return Conversation(id: conversationId,
                                        name: name,
                                        otherUserEmail: otherUserEmail,
                                        latestMessage: latestMmessageObject)
                })
                
                completion(.success(conversations))
            })
        } // end of getAllConversations
    
    // MARK: - Enums
    public enum DatabseErrors: Error {
        case failedToFetch
        
        public var localizedDescription: String {
            switch self {
            case .failedToFetch:
                return "Failed"
            }
        }
    }
} // end extension DatabaseManager

// MARK: - Structs
struct ChatEverUser {
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
