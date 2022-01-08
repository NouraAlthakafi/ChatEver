//
//  ChatVC.swift
//  ChatEver
//
//  Created by administrator on 08/01/2022.
//

import UIKit
import MessageKit

class MessagesVC: MessagesViewController {
    
    // MARK: - Variables
    private var messages = [Message]()
    private let selfSender = Sender(profilePic: "", senderId: "1", displayName: "Anonymous")

    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        messages.append(Message(sender: selfSender, messageId: "1", sentDate: Date(), kind: .text("Hello Unknown")))
        messages.append(Message(sender: selfSender, messageId: "1", sentDate: Date(), kind: .text("Hello Unknown. Hello Unknown. Hello Unknown. Hello Unknown")))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(tappedAdd))
    }
    
    // MARK: - Functions
    @objc private func tappedAdd() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "NewConversationVC") as! NewConversationVC
        let nav = UINavigationController(rootViewController: vc)
        self.present(nav, animated: true)
    }
}

// MARK: - Extensions
extension MessagesVC: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    
    func currentSender() -> SenderType {
        return selfSender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
}

// MARK: - Structs
struct Message: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}

struct Sender: SenderType {
    var profilePic: String
    var senderId: String
    var displayName: String
}
