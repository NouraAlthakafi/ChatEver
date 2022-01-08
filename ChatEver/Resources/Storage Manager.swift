//
//  Storage Manager.swift
//  ChatEver
//
//  Created by administrator on 08/01/2022.
//

import Foundation
import FirebaseStorage

final class StorageManager {
    
    // MARK: - Variables
    static let shared = StorageManager()
    private let storage = Storage.storage().reference()
    public typealias UploadPictureCompletion = (Result <String,Error>) -> Void
    
    // MARK: - Functions
    public func uploadProfilePicture(with data: Data, fileName: String, completion: @escaping UploadPictureCompletion) {
        storage.child("image/\(fileName)").putData(data, metadata: nil, completion: { metadata, error in
            
            guard error == nil else {
                // if failed
                print("Image Upload Failed \(error?.localizedDescription)")
                completion(.failure(StorageErorr.faildToUpload))
                
                return
            }
            
            self.storage.child("image/\(fileName)").downloadURL(completion: {url, error in
                guard let url = url else {
                    print("Url Download Failed \(error?.localizedDescription)")
                    completion(.failure(StorageErorr.faildToGetDownloadUrl))
                    
               return
                }
                
                let urlString = url.absoluteString
                print("Download Url returned: \(urlString)")
                completion(.success(urlString))
            })
        })
    }
    
    // MARK: - Enums
    public enum StorageErorr : Error {
        case faildToUpload
        case faildToGetDownloadUrl
    }
}
