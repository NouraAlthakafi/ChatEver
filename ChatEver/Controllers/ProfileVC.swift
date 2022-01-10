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
    
    @IBOutlet weak var ivProfile: UIImageView!
    
    @IBOutlet weak var lbUserName: UILabel!
    
    @IBOutlet weak var lbEmail: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ivProfile.layer.borderColor = UIColor.white.cgColor
        ivProfile.layer.borderWidth = 3
        ivProfile.layer.masksToBounds = true
        ivProfile.layer.cornerRadius = ivProfile.frame.size.width/2
        
        title = "Settings"
        super.viewDidAppear(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        
        guard let username = UserDefaults.standard.value(forKey: "name") as? String else {
            return
        }
        
        lbUserName.text = username
        lbEmail.text = email
        let safeEmail = DatabaseManager.emailCorrector(emailAddress: email)
        let filename = safeEmail + "_profile_picture.png"
        let path = "image/"+filename
        StorageManager.shared.downloadImageURL(for: path, completion: { result in
            switch result {
            case .success(let url):
                self.ivProfile.sd_setImage(with: url, completed: nil)
            case .failure(let error):
                print("Download Url Failed: \(error)")
            }
        })
    }
    
    
    @IBAction func logoutBtnAction(_ sender: UIButton) {
        let actionSheet = UIAlertController(title: "", message: "Are you sure?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler:{ [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            
            UserDefaults.standard.setValue(nil, forKey: "email")
            UserDefaults.standard.setValue(nil, forKey: "name")
            
            do {
                try FirebaseAuth.Auth.auth().signOut()
                let vc = strongSelf.storyboard?.instantiateViewController(withIdentifier: "SignInVC") as! SignInVC
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                
                strongSelf.present(nav, animated: true)
                
            } catch {
                print("Error Log Out User: \(error.localizedDescription)")
            }
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(actionSheet , animated: true)
        
        
    }
}
