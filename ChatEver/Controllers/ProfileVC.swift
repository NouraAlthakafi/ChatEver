//
//  ProfileVC.swift
//  ChatEver
//
//  Created by administrator on 06/01/2022.
//

import UIKit
import FirebaseAuth

class ProfileVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var ivProfilePic: UIImageView!
    @IBOutlet weak var lbFullName: UILabel!
    @IBOutlet weak var lbEmail: UILabel!
    @IBOutlet weak var btnLogOut: UIButton!
    
    // MARK: - Actions
    @IBAction func btnLogOutAction(_ sender: UIButton) {
        do {
            try FirebaseAuth.Auth.auth().signOut()
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "SignInVC") as! SignInVC
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: false)
        } catch {
            print("Error Log Out User: \(error.localizedDescription)")
        }
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
