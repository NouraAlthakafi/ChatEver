//
//  ViewController.swift
//  ChatEver
//
//  Created by administrator on 04/01/2022.
//

import UIKit

class SignInVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var ivProfilePic: UIImageView!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var btnLogIn: UIButton!
    @IBOutlet weak var btnFacebook: UIButton!
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Log In"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register", style: .done, target: self, action: #selector(didTapRegister))
    }
    
    // MARK: - ViewDidAppear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        tfEmailAttributes()
    }
    
    // MARK: - Functions
    @objc private func didTapRegister() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SignUpVC") as! SignUpVC
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    // MARK: - Attributes Functions
    func tfEmailAttributes() {
        guard let tfEmail = tfEmail else { return }
        tfEmail.autocapitalizationType = .none
        tfEmail.autocorrectionType = .no
        tfEmail.returnKeyType = .continue
        tfEmail.layer.cornerRadius = 15
        tfEmail.layer.borderWidth = 1
        tfEmail.layer.borderColor = UIColor.lightGray.cgColor
    }
    
}

