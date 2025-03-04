//
//  CreatePostView.swift
//  StockChat
//
//  Created by Macbook on 3/3/25.
//

import SwiftUI
import PhotosUI
import Firebase
import FirebaseStorage

struct CreateNewPost: View {
    // Callbacks
    var onPost: (Post) -> ()

    // Post Properties
    @State private var postText: String = ""
    @State private var postImageData: Data?

    // Stored User Data From UserDefaults (AppStorage)
    @AppStorage("user_profile_url") private var profileURL: URL?
    @AppStorage("user_name") private var userName: String = ""
    @AppStorage("user_UID") private var userUID: String = ""

    // View Properties
    @Environment(\.dismiss) private var dismiss
    @State private var isLoading: Bool = false
    @State private var errorMessage: String = ""
    @State private var showError: Bool = false
    
    @State private var showImpagePicker: Bool = false
    @State private var photoItem: PhotosPickerItem?
    @FocusState var showKeyboard: Bool
    
    var body: some View {
        VStack {
            HStack {
                Menu {
                    Button("Cancel", role: .destructive) {
                        dismiss()
                    }
                } label: {
                    Text("Cancel")
                        .font(.callout)
                        .foregroundColor(.black)
                }
                .hAlign(.leading)
                
                Button(action: createPost) {
                    Text("Post")
                        .font(.caption)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 6)
                        .background(.black, in: Capsule())
                }
                .disableWithOpacity(postText == "")
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            .background{
                Rectangle()
                    .fill(.gray.opacity(0.05))
                    .ignoresSafeArea()
            }
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 15) {
                    TextField("What's happening?", text: $postText, axis: .vertical)
                        .focused($showKeyboard)

                    if let postImageData, let image = UIImage(data: postImageData) {
                        GeometryReader {
                            let size = $0.size
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: size.width, height: size.height)
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                .overlay(alignment: .topTrailing) {
                                    Button(action: {
                                        withAnimation(.easeInOut(duration: 0.25)) {
                                            self.postImageData = nil
                                        }
                                    }) {
                                        Image(systemName: "trash")
                                            .fontWeight(.bold)
                                            .tint(.red)
                                    }
                                    .padding(10)
                                }
                                
                        }
                        .clipped()
                        .frame(height: 220)
                    }
                }
                .padding(15)
            }
            Divider()
            
            HStack {
                Button {
                    showImpagePicker.toggle()
                } label: {
                    Image(systemName: "photo.on.rectangle")
                        .font(.title3)
                }
                .hAlign(.leading)

                Button("Done") {
                    showKeyboard = false
                }
            }
            .foregroundColor(.black)
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
        }
        .vAlign(.top)
        .photosPicker(isPresented: $showImpagePicker, selection: $photoItem)
        .onChange(of: photoItem) { oldValue, newValue in
            if let newValue {
                Task {
                    if let rawImageData = try? await newValue.loadTransferable(type: Data.self),
                       let image = UIImage(data: rawImageData),
                       let compressedImageData = image.jpegData(compressionQuality: 0.5) {
                        // UI Must be done on Main Thread
                        await MainActor.run(body: {
                            postImageData = compressedImageData
                            photoItem = nil
                        })
                    }
                }
            }
        }
        .alert(errorMessage, isPresented: $showError, actions: {})
        .overlay{
            LoadingView(show: $isLoading)
        }
    }
    
    func createPost() {
        isLoading = true
        showKeyboard = false

        Task {
            do {
                guard let profileURL = profileURL else {
                    isLoading = false
                    print("=== profileURL nil")
                    return }

                // Step 1: Uploading Image If any
                // Used to delete the Post (Later shown in the Video)
                let imageReferenceID = "\(userUID)\(Date())"
                let storageRef = Storage.storage().reference().child("Post_Images").child(imageReferenceID)
                if let postImageData {
                    let _ = try await storageRef.putDataAsync(postImageData)
                    let downloadURL = try await storageRef.downloadURL()
                    // Step 3: Create Post Object With Image Id And URL
                    let post = Post(text: postText, imageURL: downloadURL
                                    , imageReferenceID: imageReferenceID
                                    , userName: userName, userUID: userUID, userProfileURL: profileURL)
                    print("post create.image", post)
                    try await createDocumentAtFirebase(post)
                } else {
                    // Step 2: Directly Post Text Data to Firebase (Since there is no Images Present)
                    let post = Post(text: postText, userName: userName, userUID: userUID, userProfileURL: profileURL)
                    print("post create", post)
                    try await createDocumentAtFirebase(post)
                }
            } catch {
                await setError(error)
            }
        }
    }
    
    func createDocumentAtFirebase(_ post: Post) async throws {
        // Writing Document to Firebase Firestore
        let doc = Firestore.firestore().collection("Posts").document()
        
        let _ = try doc.setData(from: post) { error in
            if error == nil {
                // Post Successfully Stored at Firebase
                isLoading = false
                var updatedPost = post
                updatedPost.id = doc.documentID
                onPost(updatedPost)
                dismiss()
            } else {
                print("setdata fail", error)
            }
        }
    }
    
    func setError(_ error: Error) async {
        // MARK: UI Must be Updated on Main Thread
        await MainActor.run(body: {
            errorMessage = error.localizedDescription
            showError.toggle()
            isLoading = false
        })
    }
}


struct CreatePostHeaderView: View {
    var onCancel: () -> Void
    var onPost: () -> Void

    var body: some View {
        HStack {
            Button("Cancel", role: .destructive, action: onCancel)
                .font(.callout)
                .foregroundColor(.black)
            Spacer()
            Button(action: onPost) {
                Text("Post")
                    .font(.caption)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 6)
                    .background(.black, in: Capsule())
            }
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 10)
        .background(Rectangle().fill(.gray.opacity(0.05)).ignoresSafeArea())
    }
}


struct PostContentView: View {
    @Binding var postText: String
    @Binding var postImageData: Data?
    @FocusState.Binding var showKeyboard: Bool

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 15) {
                TextField("What's happening?", text: $postText, axis: .vertical)
                    .focused($showKeyboard)

                if let postImageData, let image = UIImage(data: postImageData) {
                    GeometryReader { geometry in
                        let size = geometry.size
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: size.width, height: size.height)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .overlay(alignment: .topTrailing) {
                                Button(action: removeImage) {
                                    Image(systemName: "trash")
                                        .fontWeight(.bold)
                                        .tint(.red)
                                }
                                .padding(10)
                            }
                    }
                    .clipped()
                    .frame(height: 220)
                }
            }
            .padding(15)
        }
    }

    private func removeImage() {
        withAnimation(.easeInOut(duration: 0.25)) {
            postImageData = nil
        }
    }
}

struct PostActionToolbar: View {
    @Binding var showImagePicker: Bool
    var onDone: () -> Void

    var body: some View {
        HStack {
            Button {
                showImagePicker.toggle()
            } label: {
                Image(systemName: "photo.on.rectangle")
                    .font(.title3)
            }
            .hAlign(.leading)

            Button("Done", action: onDone)
        }
        .foregroundColor(.black)
        .padding(.horizontal, 15)
        .padding(.vertical, 10)
    }
}


struct CreateNewPostView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = CreatePostViewModel()
    @FocusState private var showKeyboard: Bool
    var onPost: (Post) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            CreatePostHeaderView(
                onCancel: { dismiss() },
                onPost: { Task {
                    await viewModel.createPost(onPost: onPost)
                    dismiss()
                } }
            )
            
            PostContentView(
                postText: $viewModel.postText,
                postImageData: $viewModel.postImageData,
                showKeyboard: $showKeyboard
            )
            
            PostActionToolbar(
                showImagePicker: $viewModel.showImagePicker,
                onDone: { viewModel.showKeyboard = false }
            )
        }
        .alert(viewModel.errorMessage, isPresented: $viewModel.showError, actions: {})
        .overlay { LoadingView(show: $viewModel.isLoading) }
        .photosPicker(isPresented: $viewModel.showImagePicker, selection: $viewModel.photoItem)
        .onChange(of: viewModel.photoItem, { oldValue, newValue in
            viewModel.handlePhotoSelection(newValue)
        })
    }
}
