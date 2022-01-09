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
    private var spinner = JGProgressHUD(style: .dark)
    
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
    
    // MARK: - Variables
    private var users = [[String: String]]()
    private var results = [[String: String]]()
    private var fetchedUsers = false
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.delegate = self
        searchBar.becomeFirstResponder()
        
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(tappedCancel))
        
        view.addSubview(label)
        view.addSubview(tableView)
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    // MARK: - ViewDidLayoutSubviews
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.frame = view.bounds
        label.frame = CGRect(x: view.width/4, y: (view.height-200)/2, width: view.width/2, height: 200)
    }
    
    // MARK: - Functions
    @objc private func tappedCancel() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - Extensions
extension NewConversationVC: UISearchBarDelegate {
    
    // MARK: - Functions
    func searchBarButtonClicked(_ searchBar: UISearchBar) {
        guard let input = searchBar.text, !input.replacingOccurrences(of: " ", with: "").isEmpty else { return }
        
        searchUsers(query: input)
        
        spinner.show(in: view)
        
        results.removeAll()

        searchBar.resignFirstResponder()
    }
    
    func searchUsers(query: String) {
        // check users exist
            if fetchedUsers {
                // if yes filter
                filterSearchUsersResult(with: query)
            } else {
                // if no fetch > filter
                DatabaseManager.shared.getAllUsers(completion: { [weak self] result in
                    switch result {
                    case .success(let usersCollection):
                        self?.users = usersCollection
                        self?.filterSearchUsersResult(with: query)
                        self?.fetchedUsers = true
                    case .failure(let error):
                        print("Usres Get Failed: \(error)")
                    }
                })
            }
        } // end function searchUsers
    
    func filterSearchUsersResult(with term: String) {
        guard fetchedUsers else { return }
        self.spinner.dismiss()
        let results: [[String: String]] = self.users.filter({
            guard let name = $0["Name"]?.lowercased() else {
                return false
            }
            return name.hasPrefix(term.lowercased())
        })
        self.results = results
        displayResult()
    } // end function filterSearchUsersResult
    
    func displayResult() {
        if results.isEmpty {
            self.label.isHidden = false
            self.tableView.isHidden = true
        } else {
            self.label.isHidden = true
            self.tableView.isHidden = false
            self.tableView.reloadData()
        }
    } // end function displayResult
} // end extension NewConversationVC UISearchBarDelegate

extension NewConversationVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellUser", for: indexPath)
        cell.textLabel?.text = results[indexPath.row]["name"]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
