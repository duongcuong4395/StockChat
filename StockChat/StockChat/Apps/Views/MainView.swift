//
//  MainView.swift
//  StockChat
//
//  Created by Macbook on 3/3/25.
//

import SwiftUI

struct MainView: View {
    @StateObject var chatVM = ChatViewModel()
    @StateObject var pageVM = PageViewModel()
    var body: some View {
        VStack {
            pageVM.page.view
        }
        .overlay(content: {
            VStack {
                HStack{
                    Image(systemName: pageVM.page == .Chat ? Page.Social.imageName : Page.Chat.imageName)
                        .font(.body)
                        .padding(7)
                        //.background(.ultraThinMaterial, in: Circle())
                        .padding(.leading)
                        //.padding(.top, pageVM.page == .Chat ? 30 : 0)
                        .onTapGesture {
                            print("=== pageVM.page", pageVM.page.rawValue)
                            withAnimation {
                                pageVM.page = pageVM.page == .Chat ? .Social : .Chat
                            }
                        }
                        .foregroundStyle(pageVM.page == .Chat ? .white : .black)
                    Spacer()
                }
                Spacer()
            }
        })
        .environmentObject(chatVM)
        .environmentObject(pageVM)
    }
}
