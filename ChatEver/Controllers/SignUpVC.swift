//
//  SignUpViewController.swift
//  ChatEver
//
//  Created by administrator on 04/01/2022.
//

import UIKit

class SignUpVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var ivProfilePic: UIImageView!
    @IBOutlet weak var tfFirstName: UITextField!
    @IBOutlet weak var tfLastName: UITextField!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var btnRegister: UIButton!
    
    // MARK: - Actions
    @IBAction func btnRegisterAction(_ sender: UIButton) {

        // closing keyboard
        tfFirstName.resignFirstResponder()
        tfLastName.resignFirstResponder()
        tfEmail.resignFirstResponder()
        tfPassword.resignFirstResponder()
        
        guard let firstName = tfFirstName.text, let lastName = tfLastName.text, let email = tfEmail.text, let password = tfPassword.text, !firstName.isEmpty, !lastName.isEmpty, !email.isEmpty, !password.isEmpty else {
            alertLogInError()
            return
        }
        
        guard let password = tfPassword.text, password.count >= 6  else {
                    alretPasswordError()
                    return
                }
        // Firebase to log in
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        title = "Create Account"
    }
    
    // MARK: - ViewDidAppear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        tfAttributes(tf: tfFirstName)
        tfAttributes(tf: tfLastName)
        tfAttributes(tf: tfEmail)
        tfAttributes(tf: tfPassword)
    }
    
    // MARK: - Alerts
    func alertLogInError() {
        let alert = UIAlertController(title: "Error", message: "Please, enter all required fields to create a new account!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    func alretPasswordError() {
        let alert = UIAlertController(title: "Error", message: "Password must be 6 characters at least.", preferredStyle: .alert)
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
