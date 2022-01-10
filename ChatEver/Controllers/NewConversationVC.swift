//
//  SignInVC.swift
//  ChatEver
//
//  Created by administrator on 06/01/2022.
//

import UIKit
import JGProgressHUD

class NewConversationVC: UIViewController {
     
//  MARK: UI Elements
        public var completion: ((SearchResult) -> (Void))?
        private let spinner = JGProgressHUD()
        private var users = [[String: String]]()
        private var results = [SearchResult]()
        private var hasFetched = false
        
        private let SearchBar : UISearchBar = {
          
            let searchBar = UISearchBar()
            searchBar.placeholder="Search for users.."
            return searchBar
        }()
    
    // TableView
        private let tabelView: UITableView = {
        
            let tabel = UITableView()
            tabel.isHidden = true
            tabel.register(NewConversationCell.self,
                                   forCellReuseIdentifier: NewConversationCell.identifier)

    
            return tabel
            
        }()
        // label
        private let noResultLabel : UILabel = {
          let label = UILabel()
            label.isHidden = true
            label.text = "No Results"
            label.textAlignment = .center
            label.textColor = .blue
            label.font = .systemFont(ofSize: 20,weight: .medium)
            
            return label
        }()
 
// MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // subViews
        view.addSubview(noResultLabel)
        view.addSubview(tabelView)
        tabelView.dataSource = self
        tabelView.delegate = self
        // search bar
        view.backgroundColor = .white
                SearchBar.delegate = self
                navigationController?.navigationBar.topItem?.titleView = SearchBar
        // canceled for search bar
                navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(tapedCancel))
               
                SearchBar.becomeFirstResponder()
    }
    
    
    @objc func tapedCancel(){
           dismiss(animated: true,completion: nil)
       }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tabelView.frame = view.bounds
        noResultLabel.frame = CGRect(x: view.width/4, y: (view.height-200)/2, width: view.width/2, height: 200)

    }
}
// MARK: Extensions
extension NewConversationVC: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
           guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else {
               return
           }

           searchBar.resignFirstResponder()

           results.removeAll()
           spinner.show(in: view)

           searchUsers(query: text)
       }

       func searchUsers(query: String) {
           // check if array has firebase results
           if hasFetched {
               // if it does: filter
               filterUsers(with: query)
           }
           else {
               // if not, fetch then filter
               DatabaseManager.shared.getAllUsers(completion: { [weak self] result in
                   switch result {
                   case .success(let usersCollection):
                       self?.hasFetched = true
                       self?.users = usersCollection
                       self?.filterUsers(with: query)
                   case .failure(let error):
                       print("Failed to get usres: \(error)")
                   }
               })
           }
       }

       func filterUsers(with term: String) {
           // update the UI: eitehr show results or show no results label
           guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String, hasFetched else {
               return
           }

           let safeEmail = DatabaseManager.emailCorrector(emailAddress: currentUserEmail)

           self.spinner.dismiss()

           let results: [SearchResult] = users.filter({
               guard let email = $0["email"], email != safeEmail else {
                   return false
               }

               guard let name = $0["name"]?.lowercased() else {
                   return false
               }

               return name.hasPrefix(term.lowercased())
           }).compactMap({

               guard let email = $0["email"],
                   let name = $0["name"] else {
                   return nil
               }

               return SearchResult(name: name, email: email)
           })

           self.results = results

           updateUI()
       }

       func updateUI() {
           if results.isEmpty {
               noResultLabel.isHidden = false
               tabelView.isHidden = true
           }
           else {
               noResultLabel.isHidden = true
               tabelView.isHidden = false
               tabelView.reloadData()
           }
       }

} // End Extension
extension NewConversationVC: UITableViewDataSource, UITableViewDelegate {func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return results.count
}

func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let model = results[indexPath.row]
    let cell = tableView.dequeueReusableCell(withIdentifier: NewConversationCell.identifier,
                                             for: indexPath) as! NewConversationCell
    cell.configure(with: model)
    return cell
}

func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    // start conversation
          let targetUserData = results[indexPath.row]

          dismiss(animated: true, completion: { [weak self] in
              self?.completion?(targetUserData)
          })
}

func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 90
}
} // End Extension
