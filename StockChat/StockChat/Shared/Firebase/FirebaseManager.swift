//
//  FirebaseManager.swift
//  StockChat
//
//  Created by Macbook on 3/3/25.
//

import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseAuth

class FirebaseManager: NSObject {
    
    let auth: Auth
    
    static let shared = FirebaseManager()
    
    override init() {
        
        self.auth = Auth.auth()
        
        super.init()
    }
}
