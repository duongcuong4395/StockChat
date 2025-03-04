//
//  StockChatView.swift
//  StockChat
//
//  Created by Macbook on 3/3/25.
//
import SwiftUI
import WebKit
import Photos

struct StockChatView: View {
    @EnvironmentObject var chatVM: ChatViewModel
    
    @AppStorage("login_status") var loginStatus: Bool = false
    
    @State private var webView = WKWebView()
    
    @State var webLoading: Bool = true
    @State var showChatView: Bool = false
    @State var showLoginView: Bool = false
    
    var body: some View {
        VStack(spacing: 0){
            getStockWebView()
            
            getChatView()
        }
        .showDialog(isShowing: $showLoginView) {
            SocialNetworkLoginView()
        }
        .onChange(of: loginStatus) { oldValue, newValue in
            if loginStatus == true {
                showLoginView = false
            }
        }
    }
    
    func startChat() {
        AppUtilities.takeScreenshot(from: webView) { image in
            guard let image = image else { return }
            Task {
                let actor = "Bạn là chuyên gia tài chính, chuyên gia chứng khoán và là nhà đầu tư \(chatVM.currentTrading.rawValue) chuyên nghiệp, với hơn 30 năm kinh nghiệm."
                
                let promptStart = actor
                + " Tôi là một nhà đầu tư mới, muốn tìm hiểu sâu để đầu tư một cách khôn khéo tránh rủi ro."
                + " Tôi sẽ đưa ra những câu hỏi hoặc hình ảnh(ví dụ như hình ảnh đính kèm này) liên quan đến \(chatVM.currentTrading.rawValue), việc của bạn là phân tích kỹ và đưa ra những góp ý hay nhất cho tôi và trình bày theo phong cách chuyên nghiệp."
                + " Trước khi bắt đầu, hãy gửi lời chào mừng đến với ứng dụng này."
                try await chatVM.chat(by: .System
                                      , with: promptStart
                                      , and: [image]//chatVM.imagesSelected
                                      , has: true
                                      , of: .gemini_2_0_flash_exp)
                
                await chatVM.aiSendSuggestIdea()
                
            }
        }
    }
    
    func onSendPromptSuggest(with promptSuggestString: String) {
        AppUtilities.takeScreenshot(from: webView) { image in
            guard let image = image else { return }
            
            Task {
                try await chatVM.chat(by: .Client, with: promptSuggestString
                                      , and: [image]//chatVM.imagesSelected
                                      , has: true
                                      , of: .gemini_2_0_flash_exp)
                await chatVM.aiSendSuggestIdea()
            }
        }
    }
    
    func onChat() {
        AppUtilities.takeScreenshot(from: webView) { image in
            guard let image = image else { return }
            
            Task {
                do {
                    chatVM.resetSuggestIdea()
                    chatVM.imagesSelected = [image]
                    try await chatVM.chat(by: .Client
                                          , with: chatVM.inputText
                                          , and: chatVM.imagesSelected
                                          , has: true
                                          , of: .gemini_2_0_flash_exp)
                    
                    chatVM.imagesSelected = []
                    await chatVM.aiSendSuggestIdea()
                } catch {
                    print("=== error", error)
                }
            }
            
        }
    }
    
    func onRemove(image: UIImage) {
        chatVM.remove(image: image)
    }
}

extension StockChatView {
    
    @ViewBuilder
    func getStockWebView() -> some View {
        StockWebView(webView: $webView, webLoading: $webLoading, currentTrading: $chatVM.currentTrading
                     , onChangeTrading: {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                chatVM.resetHistory()
                startChat()
            }
        })
            .background(.black)
            .onAppear {
                print("web onAppear")
            }
            .overlay {
                HStack {
                    Spacer()
                    VStack{
                        Spacer()
                        Image(systemName: "message")
                            .font(.body)
                            .padding(7)
                            .background(.ultraThinMaterial, in: Circle())
                            .onTapGesture {
                                withAnimation(.easeInOut) {
                                    if loginStatus {
                                        self.showChatView.toggle()
                                    } else {
                                        self.showLoginView = true
                                    }
                                }
                            }
                            .padding()
                    }
                }
            }
    }
    
    @ViewBuilder
    func getChatView() -> some View {
        if loginStatus && showChatView {
            ChatView(aiChatEvent: chatVM, inputText: $chatVM.inputText, onSendPromptSuggest: onSendPromptSuggest
                     , removeImageSelected: onRemove
                     , onSend: onChat)
            .onAppear{
                chatVM.initializeChat()
                guard chatVM.messages.count <= 0 else { return }
                startChat()
            }
            .onChange(of: webLoading, { oldValue, newValue in
                if !webLoading {
                    startChat()
                } else {
                    chatVM.resetHistory()
                }
            })
            .background(.black)
        }
    }
}
