//
//  ConversationListTVC.swift
//  ChatEver
//
//  Created by administrator on 04/01/2022.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

final class ConversationListTVC: UITableViewController { // final?
    
    // MARK: - Tools
    private let spinner = JGProgressHUD(style: .dark)
    
    // MARK: - UI Elements
    private let label: UILabel = {
            let label = UILabel()
            label.text = "No Conversations!"
            label.textAlignment = .center
            label.textColor = .gray
            label.font = .systemFont(ofSize: 20, weight: .medium)
            label.isHidden = true
            return label
        }()
    
    // MARK: - Variables
    private var conversations = [Conversation]()
    private var loginObserver: NSObjectProtocol?
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                                    target: self,
                                                                    action: #selector(tappedAdd))
        // add subviews
        view.addSubview(label)
        startListeningForConversations()
        loginObserver = Notification.default.addObserver(forName: .didLogInNotification, object: nil, queue: .main, using: { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.startListeningForConversations()
        })
    }
    
    // MARK: - ViewDidAppear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        validateAuth()
    }
    
    // MARK: - ViewDidLayoutSubviews
    override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            //tableView.frame = view.bounds
            label.frame = CGRect(x: 10, y: (view.height-100)/2, width: view.width-20, height: 100)
        }

    // MARK: - TableView Functions
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return conversations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = conversations[indexPath.row]
                let cell = tableView.dequeueReusableCell(withIdentifier: CustomCellFriend.identifier,
                                                         for: indexPath) as! CustomCellFriend
                cell.configure(with: model)
                return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let model = conversations[indexPath.row]
                openConversation(model)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 120
        }

    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
            return .delete
        }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                // begin delete
                let conversationId = conversations[indexPath.row].id
                tableView.beginUpdates()
                self.conversations.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .left)

                DatabaseManager.shared.deleteConversation(conversationId: conversationId, completion: { success in
                    if !success {
                        // add model and row back and show error alert
                    }
                })

                tableView.endUpdates()
            }
        }
    
    // MARK: - Functions
    @objc private func tappedAdd() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "NewConversationVC") as! NewConversationVC
        let nav = UINavigationController(rootViewController: vc)
        self.present(nav, animated: true)
    }
    
    private func validateAuth() {
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "SignInVC") as! SignInVC
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: false)
        }
    }
    
    private func startListeningForConversations() {
            guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
                return
            }

            if let observer = loginObserver {
                NotificationCenter.default.removeObserver(observer)
            }

            print("starting conversation fetch...")

            let safeEmail = DatabaseManager.emailCorrector(email: email)

        DatabaseManager.shared.getAllConversations(for: safeEmail, completion: { [weak self] result in
                switch result {
                case .success(let conversations):
                    print("successfully got conversation models")
                    guard !conversations.isEmpty else {
                        self?.tableView.isHidden = true
                        self?.label.isHidden = false
                        return
                    }
                    self?.label.isHidden = true
                    self?.tableView.isHidden = false
                    self?.conversations = conversations

                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                    }
                case .failure(let error):
                    self?.tableView.isHidden = true
                    self?.label.isHidden = false
                    print("failed to get convos: \(error)")
                }
            })
        } // end of startListeningForCOnversations
    
    @objc private func didTapComposeButton() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "NewConversationVC") as! NewConversationVC
            vc.completion = { [weak self] result in
                guard let strongSelf = self else {
                    return
                }

                let currentConversations = strongSelf.conversations

                if let targetConversation = currentConversations.first(where: {
                    $0.otherUserEmail == DatabaseManager.emailCorrector(email: result.email)
                }) {
                    let vc = MessagesVC(with: targetConversation.otherUserEmail, id: targetConversation.id)
                    vc.isNewConversation = false
                    vc.title = targetConversation.name
                    vc.navigationItem.largeTitleDisplayMode = .never
                    strongSelf.navigationController?.pushViewController(vc, animated: true)
                }
                else {
                    strongSelf.createNewConversation(result: result)
                }
            }
            let navVC = UINavigationController(rootViewController: vc)
            present(navVC, animated: true)
        } // end of didTapComposeButton
    
    private func createNewConversation(result: SearchResult) {
            let name = result.name
        let email = DatabaseManager.emailCorrector(email: result.email)

            // check in datbase if conversation with these two users exists
            // if it does, reuse conversation id
            // otherwise use existing code
            DatabaseManager.shared.conversationExists(with: email, completion: { [weak self] result in
                guard let strongSelf = self else {
                    return
                }
                switch result {
                case .success(let conversationId):
                    let vc = MessagesVC(with: email, id: conversationId)
                    vc.isNewConversation = false
                    vc.title = name
                    vc.navigationItem.largeTitleDisplayMode = .never
                    strongSelf.navigationController?.pushViewController(vc, animated: true)
                case .failure(_):
                    let vc = MessagesVC(with: email, id: nil)
                    vc.isNewConversation = true
                    vc.title = name
                    vc.navigationItem.largeTitleDisplayMode = .never
                    strongSelf.navigationController?.pushViewController(vc, animated: true)
                }
            })
        } // end of createNewConversation
    
    func openConversation(_ model: Conversation) {
            let vc = MessagesVC(with: model.otherUserEmail, id: model.id)
            vc.title = model.name
            vc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(vc, animated: true)
        }

}
