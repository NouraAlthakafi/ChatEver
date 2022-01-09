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
    public typealias UploadPictureCompletion = (Result<String,Error>) -> Void
    
    // MARK: - Functions
    public func uploadProfilePicture(with data: Data, fileName: String, completion: @escaping UploadPictureCompletion) {
        storage.child("image/\(fileName)").putData(data, metadata: nil, completion: { metadata, error in
            
            guard error == nil else {
                // if failed
                print("Image Upload Failed \(error?.localizedDescription)")
                completion(.failure(StorageErorrs.faildToUpload))
                
                return
            }
            
            self.storage.child("image/\(fileName)").downloadURL(completion: {url, error in
                guard let url = url else {
                    print("Url Download Failed \(error?.localizedDescription)")
                    completion(.failure(StorageErorrs.faildToGetDownloadUrl))
                    
               return
                }
                
                let urlString = url.absoluteString
                print("Download Url returned: \(urlString)")
                completion(.success(urlString))
            })
        })
    }
    
    public func downloadImageURL(for path: String, completion: @escaping (Result<URL, Error>) -> Void) {
            let reference = storage.child(path)
            reference.downloadURL(completion: { url, error in
                guard let url = url, error == nil else {
                    completion(.failure(StorageErorrs.faildToGetDownloadUrl))
                    return
                }
                completion(.success(url))
            })
        }
    
    // MARK: - Enums
    public enum StorageErorrs : Error {
        case faildToUpload
        case faildToGetDownloadUrl
    }
}
