//
//  StorageManager.swift
//  ChatEver
//
//  Created by administrator on 06/01/2022.
//

import Foundation
import FirebaseStorage
import SwiftUI

final class StorageManager {
    
    /// Shared instance of class
    static let shared = StorageManager()
    private let storage = Storage.storage().reference()
    
    public typealias UploadPictureCompletion = (Result<String,Error>) -> Void
    
    // MARK: - Functions
    public func uploadProfilePicture(with data: Data, fileName:String, completion: @escaping UploadPictureCompletion ){
        storage.child("image/\(fileName)").putData(data, metadata: nil, completion: {metadata, error in
            guard error == nil else {
                //failed
                print("Failed to upload data to firebase for Image\(String(describing: error?.localizedDescription))")
                completion(.failure(StorageErorr.faildToUpload))
                return
            }
            
            self.storage.child("image/\(fileName)").downloadURL(completion: {url, error in
                guard let url = url else {
                    print("Failed tp get download url")
                    completion(.failure(StorageErorr.faildToGetDownloadUrl))
                    return
                }
                let urlString = url.absoluteString
                print("download url returned:\(urlString)")
                completion(.success(urlString))
                
            })
        })
    } // end of uploadProfilePicture function
    
    // MARK: - Enums
    public enum StorageErorr : Error {
        case faildToUpload
        case faildToGetDownloadUrl
    }
    
    public func downloadImageURL(for path: String, completion: @escaping (Result<URL,Error>) -> Void) {
        let refrence = storage.child(path)
        
        refrence.downloadURL(completion: { url, error in
            guard let url = url, error == nil else {
                completion(.failure(StorageErorr.faildToGetDownloadUrl))
                return
                
            }
            completion(.success(url))
        })
    } // end of downloadImageURL function
}
