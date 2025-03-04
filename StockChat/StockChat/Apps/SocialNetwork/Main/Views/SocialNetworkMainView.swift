//
//  SocialNetworkMainView.swift
//  StockChat
//
//  Created by Macbook on 3/3/25.
//

import SwiftUI
import FirebaseAuth

struct SocialNetworkMainView: View {
    @AppStorage("login_status") var logStatus: Bool = false
    var body: some View {
        // MARK: TabView With Recent Post's And Profile Tabs
        TabView {
            SocialNetworkPostsView()
                .tabItem {
                    Image(systemName: "rectangle.portrait.on.rectangle.portrait.angled")
                    Text("Post's")
                }

            SocialNetworkProfileView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Profile")
                }
        }
        .tint(.black)
        .onAppear{
            guard let userID = Auth.auth().currentUser?.uid else {
                logStatus = false
                return }
        }
    }
}
