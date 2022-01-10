//
//  SignInVC.swift
//  ChatEver
//
//  Created by administrator on 06/01/2022.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class SignInVC: UIViewController {
    
    // MARK: - Tools
    private let spinner = JGProgressHUD(style: .dark)
    
    // MARK: Outlet
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Log In"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register", style: .done, target: self, action: #selector(didTapRegister))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        tfAttributes(tf: tfEmail)
        tfAttributes(tf: tfPassword)
    }
    
    // MARK: Buttons Actions
    @IBAction func loginBtnAction(_ sender: UIButton) {
        guard let email = tfEmail.text, let password = tfPassword.text, !email.isEmpty, !password.isEmpty else {
            alertLogInError()
            return
        }
        
        // Firebase Login
        Auth.auth().signIn(withEmail: email, password: password, completion: { [weak self] authResult, error in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
            }
            
            guard let result = authResult, error == nil else {
                print("Failed to log in user with email \(email)")
                return
            }
            
            let user = result.user
            let emailCorrector = DatabaseManager.emailCorrector(emailAddress: email)
            DatabaseManager.shared.getDataFor(path: emailCorrector, completion: { result in
                switch result {
                case .success(let data):
                    guard let userData = data as? [String: Any],
                          let firstName = userData["first_name"] as? String,
                          let lastName = userData["last_name"] as? String else {
                              return
                          }
                    UserDefaults.standard.set("\(firstName) \(lastName)", forKey: "name")
                    
                case .failure(let error):
                    print("Failed to read data with error \(error)")
                }
            })
            
            UserDefaults.standard.setValue(email, forKey: "email")
            print("logged in user: \(user)")
            // if this succeeds, dismiss
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        })
    }
    
    // MARK: Functions
    @objc private func didTapRegister() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SignUpVC") as! SignUpVC
        self.navigationController?.pushViewController(vc, animated: false)
    }

    // MARK: Alerts
    func alertLogInError() {
        let alert = UIAlertController(title: "Error", message: "Please, enter all required fields to log in!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    // MARK: - Attributes Functions
        func tfAttributes(tf: UITextField) {
            tf.layer.cornerRadius = 10
            tf.layer.borderWidth = 1
            tf.layer.borderColor = UIColor.lightGray.cgColor
            tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
            tf.leftViewMode = .always
        }
}
