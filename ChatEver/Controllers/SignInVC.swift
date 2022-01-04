//
//  ViewController.swift
//  ChatEver
//
//  Created by administrator on 04/01/2022.
//

import UIKit

class SignInVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var ivLogo: UIImageView!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var btnLogIn: UIButton!
    @IBOutlet weak var btnFacebook: UIButton!
    
    // MARK: - Actions
    @IBAction func btnLogInAction(_ sender: UIButton) {
        
        // closing keyboard
        tfEmail.resignFirstResponder()
        tfPassword.resignFirstResponder()
        
        guard let email = tfEmail.text, let password = tfPassword.text, !email.isEmpty, !password.isEmpty else {
            alertLogInError()
            return
        }
        // Firebase to log in
    }
    
    @IBAction func btnFacebookAction(_ sender: UIButton) {
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Log In"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register", style: .done, target: self, action: #selector(didTapRegister))
    }
    
    // MARK: - ViewDidAppear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        tfAttributes(tf: tfEmail)
        tfAttributes(tf: tfPassword)
    }
    
    // MARK: - Functions
    @objc private func didTapRegister() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SignUpVC") as! SignUpVC
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    // MARK: - Alerts
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
