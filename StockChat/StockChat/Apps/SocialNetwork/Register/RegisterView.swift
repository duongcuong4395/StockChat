//
//  RegisterView.swift
//  StockChat
//
//  Created by Macbook on 3/3/25.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import PhotosUI

// MARK: Register View

struct SocialNetworkRegisterView: View {
    // MARK: User Details
    @State var emailID: String = ""
    @State var password: String = ""
    @State var userName: String = ""
    
    @State var userBio: String = ""
    @State var userBioLink: String = ""
    
    @State var userProfilePicData: Data?

    @State var showImpagePicker: Bool = false
    @State var photoItem: PhotosPickerItem?
    
    @State var showError: Bool = false
    @State var errorMessage: String = ""
    
    @State var isLoading: Bool = false
    
    @Environment(\.dismiss) var dismiss
    
    // MARK: UserDefaults
    //@AppStorage("log_status") var logStatus: Bool = false
    @AppStorage("login_status") var loginStatus: Bool = false
    @AppStorage("user_profile_url") var profileURL: URL?
    @AppStorage("user_name") var userNameStored: String = ""
    @AppStorage("user_UID") var userUID: String = ""
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Let's register\nAccount")
                .font(.largeTitle.bold())
                .hAlign(.leading)

            Text("Hello User")
                .font(.title3)
                .hAlign(.leading)

            ViewThatFits { // For smoall size optimization
                ScrollView(.vertical, showsIndicators: false){
                    helperView()
                        
                }
                helperView()
            }
            
            
            // MARK: Register Button
            HStack {
                Text("Already have an account?")
                    .foregroundColor(.gray)

                Button("Login Now") {
                    // Hành động khi nhấn nút
                    dismiss()
                }
                .fontWeight(.bold)
                .foregroundColor(.black)
            }
            .font(.callout)
            .vAlign(.bottom)
            
        }
        .vAlign(.top)
        .padding(15)
        .overlay(content: {
            LoadingView(show: $isLoading)
        })
        .photosPicker(isPresented: $showImpagePicker, selection: $photoItem)
        .onChange(of: photoItem) { oldValue, newValue in
            // MARK: Extracting UIImage From PhotoItem
            if let newValue {
                Task {
                    do {
                        guard let imageData = try await newValue.loadTransferable(type: Data.self) else { return }
                        
                        // MARK: UI Must Be Updated on Main Thread
                        await MainActor.run(body: {
                            userProfilePicData = imageData
                        })
                    } catch {}
                }
            }
        }
        .alert(errorMessage, isPresented: $showError, actions: {})
    }
    
    @ViewBuilder
    func helperView() -> some View {
        VStack(spacing: 12) {
            
            ZStack {
                if let userProfilePicData, let image = UIImage(data: userProfilePicData) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Image(systemName: "person.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }
            }
            .frame(width: 85, height: 85)
            .clipShape(Circle())
            .contentShape(Circle())
            .onTapGesture {
                showImpagePicker.toggle()
            }
            .padding(.top, 25)
            
            TextField("UserName", text: $userName)
                .textContentType(.emailAddress)
                .border(1, color: .gray.opacity(0.5))
                .padding(.top, 25)
            
            TextField("Email", text: $emailID)
                .textContentType(.emailAddress)
                .border(1, color: .gray.opacity(0.5))
                

            SecureField("Password", text: $password)
                .textContentType(.password)
                .border(1, color: .gray.opacity(0.5))
            
            TextField("About you", text: $userBio, axis: .vertical)
                .frame(minHeight: 100, alignment: .top)
                .textContentType(.emailAddress)
                .border(1, color: .gray.opacity(0.5))
            
            TextField("Bio Link", text: $userBioLink)
                .textContentType(.emailAddress)
                .border(1, color: .gray.opacity(0.5))

            Button {
                registerUser()
            } label: {
                // MARK: Login Button
                Text("Sign up")
                    .foregroundColor(.white)
                    .hAlign(.center)
                    .fillView(.black)
                
            }
            .disableWithOpacity(userName == "" || userBio == "" || emailID == "" || password == "" || userProfilePicData == nil)
            .padding(.top, 10)
        }
    }
    
    func registerUser() {
        isLoading = true
        closeKeyboard()
        Task {
            do {
                // Step 1: Creating Firebase Account
                try await FirebaseManager.shared.auth.createUser(withEmail: emailID, password: password)

                // Step 2: Uploading Profile Photo Into Firebase Storage
                guard let userUID = FirebaseManager.shared.auth.currentUser?.uid else { return }
                guard let imageData = userProfilePicData else { return }
                let storageRef = Storage.storage().reference().child("Profile_Images").child(userUID)
                let _ = try await storageRef.putDataAsync(imageData)
                let downloadURL = try await storageRef.downloadURL()

                // Step 3: Creating a User Firestore Object
                let user = User(username: userName, userBio: userBio, userBioLink: userBioLink, userUID: userUID, userEmail: emailID, userProfileURL: downloadURL)

                // Step 4: Saving User Doc into Firestore Database
                try Firestore.firestore().collection("Users").document(userUID).setData(from: user) { error in
                    if let error = error {
                        // Handle error
                    } else {
                        print("Saved Successfully")
                        self.userNameStored = userName
                        self.userUID = userUID
                        self.profileURL = downloadURL
                        self.loginStatus = true
                        
                    }
                }
            } catch {
                // Handle error
                await setError(error)
            }
        }
    }

    // MARK: Displaying Errors VIA Alert
    func setError(_ error: Error) async {
        // MARK: UI Must be Updated on Main Thread
        await MainActor.run(body: {
            errorMessage = error.localizedDescription
            showError.toggle()
            isLoading = false
        })
    }
}
