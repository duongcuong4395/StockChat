//
//  StockChatApp.swift
//  StockChat
//
//  Created by Macbook on 3/3/25.
//

import SwiftUI
import Firebase

@main
struct StockChatApp: App {
    
    init () {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            //StockChatView()
            MainView()
        }
    }
}
