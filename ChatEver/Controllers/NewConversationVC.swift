//
//  NewConversationVC.swift
//  ChatEver
//
//  Created by administrator on 08/01/2022.
//

import UIKit
import JGProgressHUD

class NewConversationVC: UIViewController {
    
    // MARK: - Tools
    private var spinner = JGProgressHUD()
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search for Users..."
        
        return searchBar
    }()
    
    // MARK: - UI Elements
    private let tableView: UITableView = {
        let tableUsers = UITableView()
        tableUsers.isHidden = true
        tableUsers.register(UITableViewCell.self, forCellReuseIdentifier: "cellUser")
        
        return tableUsers
    }()
    
    private let label: UILabel = {
        let lbResult = UILabel()
        lbResult.isHidden = true
        lbResult.text = "No Results Found!"
        lbResult.textAlignment = .center
        lbResult.textColor = .gray
        lbResult.font = .systemFont(ofSize: 25, weight: .medium)
        
        return lbResult
    }()
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.delegate = self
        searchBar.becomeFirstResponder()
        
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(tappedCancel))
    }
    
    // MARK: - Functions
    @objc private func tappedCancel() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - Extensions
extension NewConversationVC: UISearchBarDelegate {
    
    // MARK: - Functions
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
    }
}
