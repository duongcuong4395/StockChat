//
//  PageViewModel.swift
//  StockChat
//
//  Created by Macbook on 3/3/25.
//

import SwiftUI

enum Page: String, CaseIterable{
    case Social
    case Chat
    
    @ViewBuilder
    var view: some View {
        switch self {
        case .Social:
            StockSocialView()
        case .Chat:
            StockChatView()
        }
    }
    
    var imageName: String {
        switch self {
        case .Chat:
            "message.badge.filled.fill"
        case .Social:
            "book.pages"
        }
    }
}

class PageViewModel: ObservableObject {
    @Published var page: Page = .Chat
    
    
    
}

