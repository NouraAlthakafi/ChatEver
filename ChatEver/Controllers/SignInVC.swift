//
//  ViewController.swift
//  ChatEver
//
//  Created by administrator on 04/01/2022.
//

import UIKit
import FirebaseAuth
import JGProgressHUD
import FBSDKLoginKit

class SignInVC: UIViewController {
    
    // MARK: - Tools
    private let spinner = JGProgressHUD(style: .dark)
    
    // MARK: - UI Design
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    // MARK: - Outlets
    @IBOutlet weak var ivLogo: UIImageView!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var btnLogIn: UIButton!
    
    // FaceBook
    private let loginButton = FBLoginButton()
    
    // MARK: - Actions
    @IBAction func btnLogInAction(_ sender: UIButton) {
        // closing keyboard
        tfEmail.resignFirstResponder()
        tfPassword.resignFirstResponder()
        
        guard let email = tfEmail.text, let password = tfPassword.text, !email.isEmpty, !password.isEmpty else {
            alertLogInError()
            return
        }
        
        // spinner
        spinner.show(in: view)
        
        // Firebase to log in
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: { [weak self] authResult, error in
            guard let strongSelf = self else { return }
            
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
            }
            
            guard let result = authResult, error == nil else {
                print("User Log in Error with Email: \(email)")
                return
            }
            
            let user = result.user
            
            UserDefaults.standard.setValue(email, forKey: "email")
            
            print("\(user) Logged in Success!")
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        })
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Log In"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register", style: .done, target: self, action: #selector(tappedRegister))
        
        // Add Subviews
        view.addSubview(loginButton)
    }
    
    // MARK: - ViewDidAppear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        tfAttributes(tf: tfEmail)
        tfAttributes(tf: tfPassword)
        
        loginButton.center = scrollView.center
        loginButton.frame.origin.x = loginButton.left+160
        loginButton.frame.origin.y = loginButton.bottom+370
    }
    
    // MARK: - Functions
    @objc private func tappedRegister() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SignUpVC") as! SignUpVC
        self.navigationController?.pushViewController(vc, animated: false)
        /*let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: false)*/
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
