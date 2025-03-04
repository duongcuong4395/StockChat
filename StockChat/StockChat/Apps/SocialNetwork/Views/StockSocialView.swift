//
//  StockSocialView.swift
//  StockChat
//
//  Created by Macbook on 3/3/25.
//

import SwiftUI

struct StockSocialView: View {
    
    @AppStorage("login_status") var loginStatus: Bool = false
    
    var body: some View {
        if loginStatus {
            SocialNetworkMainView()
        } else {
            SocialNetworkLoginView()
        }
    }
}
