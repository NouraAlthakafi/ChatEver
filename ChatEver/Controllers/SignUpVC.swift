//
//  SignUpVC.swift
//  ChatEver
//
//  Created by administrator on 06/01/2022.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class SignUpVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var ivProfile: UIImageView!
    @IBOutlet weak var tfFirstName: UITextField!
    @IBOutlet weak var tfLastName: UITextField!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        ivProfile.layer.cornerRadius = ivProfile.frame.size.width/2
        title = "Create Account"
        view.backgroundColor = .white
        ivProfile.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.presentPhotoActionSheet))
        ivProfile.addGestureRecognizer(gesture)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        tfAttributes(tf: tfFirstName)
        tfAttributes(tf: tfLastName)
        tfAttributes(tf: tfEmail)
        tfAttributes(tf: tfPassword)
    }
    
    // MARK: Buttons Actions
    @IBAction func btnRegisterAction(_ sender: UIButton) {
        guard let firstName = tfFirstName.text, let lastName = tfLastName.text, let email = tfEmail.text , let nPass = tfPassword.text, !firstName.isEmpty, !lastName.isEmpty , !email.isEmpty, !nPass.isEmpty else {
            alertRegisterError()
            return
    }
    
        // Firebase Login
        DatabaseManager.shared.userExistence(with: email, completion: { [weak self] exists in
            guard let strongSelf = self else { return }
            
            guard !exists else {
                // user already exists
                strongSelf.alretPasswordError()
                return
            }
            Auth.auth().createUser(withEmail: email, password: nPass, completion: { authResult, error in
                
                guard authResult != nil, error == nil else{
                    print("Error Creating User")
                    return
                }
                UserDefaults.standard.setValue(email, forKey: "email")
                UserDefaults.standard.setValue("\(firstName) \(lastName)", forKey: "name")
                
                let chatUser = ChatEverUser(firstName: firstName, lastName: lastName, emailAddress: email)
                DatabaseManager.shared.insertUser(with: chatUser,completion: { success in
                    if success {
                        //upload image
                        guard let image = strongSelf.ivProfile.image,
                              let data = image.pngData() else {
                                  return
                              }
                        let fileName = chatUser.profilePictureFileName
                        StorageManager.shared.uploadProfilePicture(with: data, fileName: fileName, completion: { result in
                            switch result{
                            case.success(let downloadUrl):
                                UserDefaults.standard.setValue(downloadUrl, forKey: "profile_picture_url")
                                print(downloadUrl)
                            case.failure(let error):
                                print("Storage manger error\(error)")
                            }
                            
                        })
                        
                    }
                })
                strongSelf.navigationController?.dismiss(animated: true, completion: nil)
            })
        })
    }
    
    
    // MARK: Alerts
    func alertRegisterError() {
        let alert = UIAlertController(title: "Error", message: "Please, enter all required fields to log in!", preferredStyle: .alert)
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
} // End of class

// MARK: Extensions
extension SignUpVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // get results of user taking picture or selecting from camera roll
    
    @objc func presentPhotoActionSheet(){
        let actionSheet = UIAlertController(title: "Profile Picture", message: "How would you like to select a picture?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { [weak self] _ in
            self?.presentCamera()
        }))
        actionSheet.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: { [weak self] _ in
            self?.presentPhotoPicker()
        }))
        
        present(actionSheet, animated: true)
    }
    func presentCamera() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    func presentPhotoPicker() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // take a photo or select a photo
        
        // action sheet - take photo or choose photo
        picker.dismiss(animated: true, completion: nil)
        print(info)
        
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        
        self.ivProfile.image = selectedImage
        
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}
