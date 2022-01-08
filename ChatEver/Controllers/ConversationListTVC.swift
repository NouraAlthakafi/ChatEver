//
//  ConversationListTVC.swift
//  ChatEver
//
//  Created by administrator on 04/01/2022.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class ConversationListTVC: UITableViewController {
    
    // MARK: - Tools
    private let spinner = JGProgressHUD(style: .dark)
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        /*do {
            try FirebaseAuth.Auth.auth().signOut()
        } catch {
            print(error.localizedDescription)
        }*/
    }
    
    // MARK: - ViewDidAppear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        validateAuth()
        allConvorsations()
    }

    // MARK: - TableView Functions
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellFriend", for: indexPath)
        cell.textLabel?.text = "Hello World!"
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChatVC") as! MessagesVC
        vc.title = "Unknown"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
        //let nav = UINavigationController(rootViewController: vc)
        //nav.modalPresentationStyle = .fullScreen
        //self.present(nav, animated: true)
    }
    
    // MARK: - Functions
    private func validateAuth() {
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "SignInVC") as! SignInVC
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: false)
        }
    }
    
    private func allConvorsations() {
        // firebase to restore
    }
}
