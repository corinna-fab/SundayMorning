//
//  StorageManager.swift
//  Sunday Morning 2
//
//  Created by Corinna Fabre on 7/8/20.
//  Copyright © 2020 Corinna Fabre. All rights reserved.
//

import Foundation
import FirebaseStorage
import FirebaseAuth

final class StorageManager {
    static let shared = StorageManager()
    
    private var storage = Storage.storage().reference()
    
    private var currentUser = FirebaseAuth.Auth.auth().currentUser
    
    public typealias UploadPictureCompletion = (Result<String, Error>) -> Void
    
    /// Uploads picture to firebase storage and returns a completion with URL string to download
    public func uploadProfilePicture(with data: Data, fileName: String, completion: @escaping UploadPictureCompletion) {
        storage.child("images/\(fileName)").putData(data, metadata: nil, completion: { metadata, error in
            guard error == nil else {
                //Failed
                print("Failed to upload data to firebase for profile picture")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            self.storage.child("images/\(fileName)").downloadURL(completion: { url, error in
                guard let url = url else {
                    print("Failed to get download URL")
                    completion(.failure(StorageErrors.failedToGetDownloadURL))
                    return
                }
                
                let urlString = url.absoluteString
                print("Download URL returned: \(urlString)")
                    completion(.success(urlString))
            })
        })
    }
    
    /// Uploads books to firebase storage and returns a completion with URL string to download
//    public func uploadBook(with data: Data, fileName: String, completion: @escaping UploadBookCompletion) {
//        storage.child("images/\(fileName)").putData(data, metadata: nil, completion: { metadata, error in
//            guard error == nil else {
//                //Failed
//                print("Failed to upload data to firebase for profile picture")
//                completion(.failure(StorageErrors.failedToUpload))
//                return
//            }
//            self.storage.child("images/\(fileName)").downloadURL(completion: { url, error in
//                guard let url = url else {
//                    print("Failed to get download URL")
//                    completion(.failure(StorageErrors.failedToGetDownloadURL))
//                    return
//                }
//                
//                let urlString = url.absoluteString
//                print("Download URL returned: \(urlString)")
//                    completion(.success(urlString))
//            })
//        })
//    }
    
    public enum StorageErrors: Error {
        case failedToUpload
        case failedToGetDownloadURL
    }
}
