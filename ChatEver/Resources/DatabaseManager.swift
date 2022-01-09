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
                print(99)
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
    
    /// Gets all mmessages for a given conversatino
        public func getAllMessagesForConversation(with id: String, completion: @escaping (Result<[Message], Error>) -> Void) {
            database.child("\(id)/messages").observe(.value, with: { snapshot in
                guard let value = snapshot.value as? [[String: Any]] else{
                    completion(.failure(DatabseErrors.failedToFetch))
                    return
                }
                
                let messages: [Message] = value.compactMap({ dictionary in
                    guard let name = dictionary["name"] as? String,
                          let _ = dictionary["is_read"] as? Bool,
                          let messageID = dictionary["id"] as? String,
                          let content = dictionary["content"] as? String,
                          let senderEmail = dictionary["sender_email"] as? String,
                          let _ = dictionary["type"] as? String,
                          let dateString = dictionary["date"] as? String,
                          let date = MessagesVC.dateFormatter.date(from: dateString)else {
                              return nil
                          }
                    
                    let sender = Sender(photoURL: "",
                                        senderId: senderEmail,
                                        displayName: name)
                    
                    return Message(sender: sender,
                                   messageId: messageID,
                                   sentDate: date,
                                   kind: .text(content))
                })
                completion(.success(messages))
            })
        } // end of getAllMessagesForConversation
    
    /// Sends a message with target conversation and message
        public func sendMessage(to conversation: String, otherUserEmail: String, name: String, newMessage: Message, completion: @escaping (Bool) -> Void) {
            // add new message to messages
            // update sender latest message
            // update recipient latest message
            guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
                completion(false)
                return
            }
            
            let currentEmail = DatabaseManager.emailCorrector(email: myEmail)
            database.child("\(conversation)/messages").observeSingleEvent(of: .value, with: { [weak self] snapshot in
                guard let strongSelf = self else {
                    return
                }
                
                guard var currentMessages = snapshot.value as? [[String: Any]] else {
                    completion(false)
                    return
                }
                
                let messageDate = newMessage.sentDate
                let dateString = MessagesVC.dateFormatter.string(from: messageDate)
                
                var message = ""
                switch newMessage.kind {
                case .text(let messageText):
                    message = messageText
                case .attributedText(_):
                    break
                case .photo(let mediaItem):
                    if let targetUrlString = mediaItem.url?.absoluteString {
                        message = targetUrlString
                    }
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
                
                guard let myEmmail = UserDefaults.standard.value(forKey: "email") as? String else {
                    completion(false)
                    return
                }
                
                let currentUserEmail = DatabaseManager.emailCorrector(email: myEmmail)
                
                let newMessageEntry: [String: Any] = [
                    "id": newMessage.messageId,
                    "type": newMessage.kind.messageKindString,
                    "content": message,
                    "date": dateString,
                    "sender_email": currentUserEmail,
                    "is_read": false,
                    "name": name
                ]
                
                currentMessages.append(newMessageEntry)
                
                strongSelf.database.child("\(conversation)/messages").setValue(currentMessages) { error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    
                    strongSelf.database.child("\(currentEmail)/conversations").observeSingleEvent(of: .value, with: { snapshot in
                        guard var currentUserConversations = snapshot.value as? [[String: Any]] else {
                            completion(false)
                            return
                        }

                        let updatedValue: [String: Any] = [
                            "date": dateString,
                            "is_read": false,
                            "message": message
                        ]

                        var targetConversation: [String: Any]?
                        var position = 0

                        for conversationDictionary in currentUserConversations {
                            if let currentId = conversationDictionary["id"] as? String, currentId == conversation {
                                targetConversation = conversationDictionary
                                break
                            }
                            position += 1
                        }

                        targetConversation?["latest_message"] = updatedValue
                        guard let finalConversation = targetConversation else{
                            completion(false)
                            return
                        }

                        currentUserConversations[position] = finalConversation
                        strongSelf.database.child("\(currentEmail)/conversations").setValue(currentUserConversations, withCompletionBlock: { error, _ in
                            guard error == nil else {
                                completion(false)
                                return
                            }


                            // Update latest message for recipient user
                            strongSelf.database.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value, with: { snapshot in
                                guard var otherUserConversations = snapshot.value as? [[String: Any]] else {
                                    completion(false)
                                    return
                                }

                                let updatedValue: [String: Any] = [
                                    "date": dateString,
                                    "is_read": false,
                                    "message": message
                                ]

                                var targetConversation: [String: Any]?
                                var position = 0

                                for conversationDictionary in otherUserConversations {
                                    if let currentId = conversationDictionary["id"] as? String, currentId == conversation {
                                        targetConversation = conversationDictionary
                                        break
                                    }
                                    position += 1
                                }

                                targetConversation?["latest_message"] = updatedValue
                                guard let finalConversation = targetConversation else{
                                    completion(false)
                                    return
                                }

                                otherUserConversations[position] = finalConversation
                                strongSelf.database.child("\(otherUserEmail)/conversations").setValue(otherUserConversations, withCompletionBlock: { error, _ in
                                    guard error == nil else {
                                        completion(false)
                                        return
                                    }

                                    completion(true)
                                })
                            })
                        })
                    })
                }
            })
        } // end of sendMessages
    
    public func deleteConversation(conversationId: String, completion: @escaping (Bool) -> Void) {
                guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
                    return
                }
                let safeEmail = DatabaseManager.emailCorrector(email: email)

                print("Deleting conversation with id: \(conversationId)")

                // Get all conversations for current user
                // delete conversation in collection with target id
                // reset those conversations for the user in database
                let ref = database.child("\(safeEmail)/conversations")
                ref.observeSingleEvent(of: .value) { snapshot in
                    if var conversations = snapshot.value as? [[String: Any]] {
                        var positionToRemove = 0
                        for conversation in conversations {
                            if let id = conversation["id"] as? String,
                                id == conversationId {
                                print("found conversation to delete")
                                break
                            }
                            positionToRemove += 1
                        }

                        conversations.remove(at: positionToRemove)
                        ref.setValue(conversations, withCompletionBlock: { error, _  in
                            guard error == nil else {
                                completion(false)
                                print("faield to write new conversatino array")
                                return
                            }
                            print("deleted conversaiton")
                            completion(true)
                        })
                    }
                }
            } // end of deleteConversation
    
    public func conversationExists(with targetRecipientEmail: String, completion: @escaping (Result<String, Error>) -> Void) {
                let safeRecipientEmail = DatabaseManager.emailCorrector(email: targetRecipientEmail)
                guard let senderEmail = UserDefaults.standard.value(forKey: "email") as? String else {
                    return
                }
                let safeSenderEmail = DatabaseManager.emailCorrector(email: senderEmail)

                database.child("\(safeRecipientEmail)/conversations").observeSingleEvent(of: .value, with: { snapshot in
                    guard let collection = snapshot.value as? [[String: Any]] else {
                        completion(.failure(DatabseErrors.failedToFetch))
                        return
                    }
                    // iterate and find conversation with target sender
                    if let conversation = collection.first(where: {
                        guard let targetSenderEmail = $0["other_user_email"] as? String else {
                            return false
                        }
                        return safeSenderEmail == targetSenderEmail
                    }) {
                        // get id
                        guard let id = conversation["id"] as? String else {
                            completion(.failure(DatabseErrors.failedToFetch))
                            return
                        }
                        completion(.success(id))
                        return
                    }

                    completion(.failure(DatabseErrors.failedToFetch))
                    return
                })
            } // end of conversationExists

    
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
