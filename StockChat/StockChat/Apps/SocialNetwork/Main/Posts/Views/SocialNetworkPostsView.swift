//
//  SocialNetworkPostsView.swift
//  StockChat
//
//  Created by Macbook on 3/3/25.
//

import SwiftUI
import FirebaseAuth

struct SocialNetworkPostsView: View {
    @State private var myProfile: User?
    @State private var recentsPosts: [Post] = []
    @State private var createNewPost: Bool = false

    @AppStorage("user_profile_url") private var profileURL: URL?
    @AppStorage("user_name") private var userName: String = ""
    @AppStorage("user_UID") private var userUID: String = ""
    
    var body: some View {
        NavigationStack{
            ReusablePostsView(posts: $recentsPosts)
                .hAlign(.center)
                .vAlign(.center)
                .overlay(alignment: .bottomTrailing) {
                    Button {
                        createNewPost.toggle()
                    } label: {
                        Image(systemName: "plus")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(13)
                            .background(.black, in: Circle())
                    }
                    .padding(15)
                }
                .toolbar(content: {
                    ToolbarItem(placement: .navigationBarTrailing, content: {
                        NavigationLink {
                            SearchUserView()
                        } label: {
                            Image(systemName: "magnifyingglass")
                                .tint(.black)
                                .scaleEffect(0.9)
                        }
                    })
                })
                .navigationTitle("Post's")
        }
        .task {
            if myProfile != nil { return }
            print("=== fetchUserData")
            await fetchUserData()
        }
        .fullScreenCover(isPresented: $createNewPost) {
            
            /*
            CreateNewPostView{ post in
                // Xử lý khi tạo bài đăng mới thành công
                recentsPosts.insert(post, at: 0)
            }
            */
            
            CreateNewPost { post in
                // Xử lý khi tạo bài đăng mới thành công
                recentsPosts.insert(post, at: 0)
            }
            
            
        }
    }
    
    func fetchUserData() async {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        guard let user = try? await Firestore.firestore().collection("Users").document(userID).getDocument(as: User.self) else { return }
        
        await MainActor.run(body: {
            myProfile = user
            
            userUID = userID
            userName = user.username
            profileURL = user.userProfileURL
        })
    }
    
}

import PhotosUI
import Firebase
import FirebaseStorage
import FirebaseFirestore

struct SearchUserView: View {
    // State properties
    @State private var fetchedUsers: [User] = []
    @State private var searchText: String = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List {
            ForEach(fetchedUsers) { user in
                NavigationLink {
                    ReusableProfileContent(user: user)
                } label: {
                    Text(user.username)
                        .font(.callout)
                        .hAlign(.leading)
                }
            }
        }
        .listStyle(.plain)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Search User")
        .searchable(text: $searchText)
        .onSubmit(of: .search) {
            Task{
                await searchUsers()
            }
        }
        .onChange(of: searchText, { oldValue, newValue in
            if newValue.isEmpty{
                fetchedUsers = []
            } else {
                Task{
                    await searchUsers()
                }
            }
        })
        /*
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Cancel") {
                    dismiss()
                }
                .tint(.black)
            }
        }
        */
    }
    
    func searchUsers() async {
        do {
            

            let documents = try await Firestore.firestore().collection("Users")
                .whereField("username", isGreaterThanOrEqualTo: searchText)
                .whereField("username", isLessThanOrEqualTo: "\(searchText)\u{f8ff}")
                .getDocuments()

            let users = try documents.documents.compactMap { doc -> User? in
                try doc.data(as: User.self)
            }

            // UI Must be Updated on Main Thread
            await MainActor.run(body: {
                fetchedUsers = users
            })
        } catch {
            print(error.localizedDescription)
        }
    }
}



