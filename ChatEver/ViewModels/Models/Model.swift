//
//  Model.swift
//  ChatEver
//
//  Created by administrator on 09/01/2022.
//

import Foundation

// MARK: - Enums
// profileViewModel
enum ProfileViewModelType {
    case info, logout
}

// MARK: - Structs
// conversation
struct Conversation {
    let id: String
    let name: String
    let otherUserEmail: String
    let latestMessage: LatestMessage
}

struct LatestMessage {
    let date: String
    let text: String
    let isRead: Bool
}

// profileViewModel
struct ProfileViewModel {
    let viewModelType: ProfileViewModelType
    let title: String
    let handler: (() -> Void)?
}

// searchResult
struct SearchResult {
    let name: String
    let email: String
}
