//
//  ViewController.swift
//  ChatEver
//
//  Created by administrator on 04/01/2022.
//

import UIKit

class SignInVC: UIViewController {

    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        title = "Log In"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register", style: .done, target: self, action: #selector(didTapRegister))
    }
    
    // MARK: - Functions
    @objc private func didTapRegister() {
        let vc = SignUpVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

