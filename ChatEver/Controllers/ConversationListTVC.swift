//
//  ConversationListTVC.swift
//  ChatEver
//
//  Created by administrator on 04/01/2022.
//

import UIKit
import FirebaseAuth

class ConversationListTVC: UITableViewController {
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - ViewDidAppear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        validateAuth()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
    
    // MARK: - Functions
    private func validateAuth() {
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "SignInVC") as! SignInVC
            self.navigationController?.pushViewController(vc, animated: false)
        }
    }
}
