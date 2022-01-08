//
//  SignUpViewController.swift
//  ChatEver
//
//  Created by administrator on 04/01/2022.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class SignUpVC: UIViewController {
    
    // MARK: - Tools
    private let spinner = JGProgressHUD(style: .dark)
    
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
        
        spinner.show(in: view)
        
        // Firebase to create account
        DatabaseManager.shared.validateUserExistence(with: email, completion: { [weak self] exists in
            guard let strongSelf = self else { return }
            
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
            }
            
            guard !exists else {
                strongSelf.alretUserExist()
                return
            }
            
            FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: { authResult, error in
                guard authResult != nil, error == nil else {
                    print("User Creating Error: \(String(describing: error?.localizedDescription))")
                    return
                }
                
                DatabaseManager.shared.insertUser(with: ChatEverUser(firstName: firstName, lastName: lastName, email: email))
                
                strongSelf.navigationController?.dismiss(animated: true, completion: nil)
            })
        })
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        title = "Create Account"
        
        let tappedIVProfile = UITapGestureRecognizer(target: self, action: #selector(self.presentPhotoActionSheet))
        ivProfilePic.isUserInteractionEnabled = true
        ivProfilePic.addGestureRecognizer(tappedIVProfile)
        
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
    func alretUserExist() {
        let alert = UIAlertController(title: "Error", message: "This account is already registered!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
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

// MARK: - Extensions
extension SignUpVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // get results of user taking picture or selecting from camera roll
    @objc func presentPhotoActionSheet() {
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
        
        self.ivProfilePic.image = selectedImage
        
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}
