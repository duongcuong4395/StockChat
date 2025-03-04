//
//  SocialNetworkLoginView.swift
//  StockChat
//
//  Created by Macbook on 3/3/25.
//

import SwiftUI
import PhotosUI
import Firebase
import FirebaseAuth

import FirebaseFirestore
import FirebaseStorage


struct SocialNetworkLoginView: View {
    // MARK: User Details
    @State var emailID: String = ""
    @State var password: String = ""
    @State var createAccount: Bool = false

    @State var showError: Bool = false
    @State var errorMessage: String = ""
    
    @State var isLoading: Bool = false
    
    // MARK: UserDefaults
    //@AppStorage("log_status") var logStatus: Bool = false
    @AppStorage("login_status") var loginStatus: Bool = false
    @AppStorage("user_profile_url") var profileURL: URL?
    @AppStorage("user_name") var userNameStored: String = ""
    @AppStorage("user_UID") var userUID: String = ""
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Let's Sign you in")
                .font(.largeTitle.bold())
                .hAlign(.leading)

            Text("Welcome Back, \nYou have been missed")
                .font(.title3)
                .hAlign(.leading)

            VStack(spacing: 12) {
                TextField("Email", text: $emailID)
                    .textContentType(.emailAddress)
                    .border(1, color: .gray.opacity(0.5))
                    .padding(.top, 25)

                SecureField("Password", text: $password)
                    .textContentType(.password)
                    .border(1, color: .gray.opacity(0.5))
                
                Button("Reset password?", action: resetPassword)
                    .font(.callout)
                    .fontWeight(.medium)
                    .tint(.black)
                    .hAlign(.trailing)

                Button {
                    loginUser()
                } label: {
                    // MARK: Login Button
                    Text("Sign in")
                        .foregroundColor(.white)
                        .hAlign(.center)
                        .fillView(.black)
                }
                .padding(.top, 10)
            }
            
            // MARK: Register Button
            HStack {
                Text("Don't have an account?")
                    .foregroundColor(.gray)

                Button("Register Now") {
                    createAccount.toggle()
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
        .fullScreenCover(isPresented: $createAccount, content: {
            SocialNetworkRegisterView()
        })
        .alert(errorMessage, isPresented: $showError, actions: {})
    }
    
    func loginUser() {
        isLoading = true
        closeKeyboard()
        Task {
            do {
                //  Auth.auth()
                try await FirebaseManager.shared.auth.signIn(withEmail: emailID, password: password)
                print("User Found")
                loginStatus = true
            } catch {
                await setError(error)
            }
        }
    }
    
    func resetPassword() {
        Task {
            do {
                try await FirebaseManager.shared.auth.sendPasswordReset(withEmail: emailID)
                print("Link Sent")
                try await fetchUser()
            } catch {
                await setError(error)
            }
        }
    }
    
    // MARK: If User if Found then Fetching User Data From Firestore
    func fetchUser() async throws {
        guard let userID = FirebaseManager.shared.auth.currentUser?.uid else { return }
        let user = try await Firestore.firestore().collection("Users").document(userID).getDocument(as: User.self)

        // MARK: UI Updating Must be Run On Main Thread
        await MainActor.run(body: {
            // Setting UserDefaults data and Changing App's Auth Status
            userUID = userID
            userNameStored = user.username
            profileURL = user.userProfileURL
            loginStatus = true
            print("")
        })
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

import SwiftUI
//import FirebaseFirestoreSwift

struct User: Identifiable, Codable {
    @DocumentID var id: String?
    var username: String
    var userBio: String
    var userBioLink: String
    var userUID: String
    var userEmail: String
    var userProfileURL: URL

    enum CodingKeys: CodingKey {
        case id
        case username
        case userBio
        case userBioLink
        case userUID
        case userEmail
        case userProfileURL
    }
}
