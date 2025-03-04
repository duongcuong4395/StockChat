//
//  PostsViewModel.swift
//  StockChat
//
//  Created by Macbook on 3/3/25.
//

import SwiftUI
import Firebase
import FirebaseStorage

import Firebase
import FirebaseStorage
import PhotosUI

@MainActor
class CreatePostViewModel: ObservableObject {
    // Post Properties
    @Published var postText: String = ""
    @Published var postImageData: Data?
    
    // UI State
    @Published var showKeyboard: Bool = false
    @Published var showImagePicker: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    @Published var showError: Bool = false
    
    // Photo Picker
    @Published var photoItem: PhotosPickerItem?

    // Stored User Data
    @AppStorage("user_profile_url") private var profileURL: URL?
    @AppStorage("user_name") private var userName: String = ""
    @AppStorage("user_UID") private var userUID: String = ""

    // MARK: - Handle Photo Selection
    func handlePhotoSelection(_ newValue: PhotosPickerItem?) {
        guard let newValue else { return }
        Task {
            do {
                if let rawImageData = try await newValue.loadTransferable(type: Data.self),
                   let image = UIImage(data: rawImageData),
                   let compressedImageData = image.jpegData(compressionQuality: 0.5) {
                    self.postImageData = compressedImageData
                }
            } catch {
                await self.setError(error)
            }
        }
    }

    // MARK: - Create New Post
    func createPost(onPost: @escaping (Post) -> Void) async {
        isLoading = true
        showKeyboard = false

        do {
            guard let profileURL = profileURL else {
                isLoading = false
                print("=== profileURL nil")
                return
            }

            let imageReferenceID = "\(userUID)\(Date())"
            let storageRef = Storage.storage().reference().child("Post_Images").child(imageReferenceID)
            print("=== imageReferenceID", imageReferenceID)
            if let postImageData {
                let _ = try await storageRef.putDataAsync(postImageData)
                let downloadURL = try await storageRef.downloadURL()
                let post = Post(
                    text: postText,
                    imageURL: downloadURL,
                    imageReferenceID: imageReferenceID,
                    userName: userName,
                    userUID: userUID,
                    userProfileURL: profileURL
                )
                
                try await createDocumentAtFirebase(post, onPost: onPost)
            } else {
                let post = Post(text: postText, userName: userName, userUID: userUID, userProfileURL: profileURL)
                try await createDocumentAtFirebase(post, onPost: onPost)
            }
        } catch {
            await setError(error)
        }
    }

    private func createDocumentAtFirebase(_ post: Post, onPost: @escaping (Post) -> Void) async throws {
        let doc = Firestore.firestore().collection("Posts").document()
        let _ = try doc.setData(from: post) { error in
            if error == nil {
                self.isLoading = false
                var updatedPost = post
                updatedPost.id = doc.documentID
                DispatchQueue.main.async {
                    onPost(updatedPost)
                }
            } else {
                print("setdata fail", error)
            }
        }
        //isLoading = false
    }
    
    func createDocumentAtFirebase(_ post: Post) async throws {
        // Writing Document to Firebase Firestore
        let doc = Firestore.firestore().collection("Posts").document()
        
        let _ = try doc.setData(from: post) { error in
            if error == nil {
                // Post Successfully Stored at Firebase
                self.isLoading = false
                var updatedPost = post
                updatedPost.id = doc.documentID
                //onPost(updatedPost)
                //dismiss()
            } else {
                print("setdata fail", error)
            }
        }
    }

    private func setError(_ error: Error) async {
        await MainActor.run {
            errorMessage = error.localizedDescription
            showError.toggle()
            isLoading = false
        }
    }

    // MARK: - Handle Errors
    private func setError(_ error: Error) {
        self.errorMessage = error.localizedDescription
        self.showError = true
        self.isLoading = false
    }
}


protocol PostServiceProtocol {
    func uploadImage(data: Data, for referenceID: String) async throws -> URL
    func createPost(_ post: Post) async throws -> Post
}

class PostService: PostServiceProtocol {
    func uploadImage(data: Data, for referenceID: String) async throws -> URL {
        let storageRef = Storage.storage().reference().child("Post_Images").child(referenceID)
        let _ = try await storageRef.putDataAsync(data)
        return try await storageRef.downloadURL()
    }
    
    func createPost(_ post: Post) async throws -> Post {
        let doc = Firestore.firestore().collection("Posts").document()
        try doc.setData(from: post)
        var updatedPost = post
        updatedPost.id = doc.documentID
        return updatedPost
    }
}
