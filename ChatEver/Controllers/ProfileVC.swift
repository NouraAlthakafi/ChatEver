//
//  ProfileVC.swift
//  ChatEver
//
//  Created by administrator on 06/01/2022.
//

import UIKit
import FirebaseAuth
import SDWebImage

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
        
        // Image Attributes
        ivProfilePic.layer.borderColor = UIColor.white.cgColor
        ivProfilePic.layer.borderWidth = 3
        ivProfilePic.layer.masksToBounds = true
        ivProfilePic.layer.cornerRadius = ivProfilePic.frame.size.width/2
    }
    
    // MARK: - ViewDidAppear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        
        let emailCorrector = DatabaseManager.emailCorrector(email: email)
        let fileName = emailCorrector + "_profile_picture.png"
        let path = "image/\(fileName)"
        StorageManager.shared.downloadImageURL(for: path, completion: { result in
            switch result {
            case .success(let url):
                DispatchQueue.main.async {
                    self.ivProfilePic.sd_setImage(with: url, completed: nil)
                }
            case .failure(let error):
                print("Download Url Failed: \(error)")
            }
        })
    }
}
