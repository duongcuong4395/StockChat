//
//  ChatHistoryView.swift
//  StockChat
//
//  Created by Macbook on 3/3/25.
//

import SwiftUI
import GeminiAI

struct ChatHistoryView: View {
    
    var messages: [ChatMessage]
    var promptsSuggest: [PromptsSuggest]
    var showImageFromClient: Bool = true
    
    var resetPromptSuggest: () -> Void
    var sendPromptSuggest: (_ prompt: PromptsSuggest) -> Void
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(messages) { message in
                        MessageBubbleView(message: message, showImageFromClient: showImageFromClient)
                            .id(message.id)
                    }
                    if !promptsSuggest.isEmpty {
                        HStack{
                            Text("Suggest:")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.9))
                            Spacer()
                        }
                    }
                    PromptsSuggestView(promptsSug: promptsSuggest) { promptSuggest in
                        Task {
                            let prt = promptSuggest
                            resetPromptSuggest()
                            sendPromptSuggest(prt)
                        }
                    }
                }
            }
            .onChange(of: messages) { _, _ in
                scrollToBottom(proxy: proxy)
            }
            .onChange(of: promptsSuggest) { _, _ in
                scrollToBottom2(proxy: proxy)
            }
            .onAppear {
                scrollToBottom(proxy: proxy)
            }
        }
    }
    
    // Hàm cuộn xuống cuối cùng
    private func scrollToBottom(proxy: ScrollViewProxy) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if let lastID = messages.last?.id {
                withAnimation {
                    proxy.scrollTo(lastID, anchor: .bottom)
                }
            }
        }
    }
    
    private func scrollToBottom2(proxy: ScrollViewProxy) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if let lastID = promptsSuggest.last?.id {
                withAnimation {
                    proxy.scrollTo(lastID, anchor: .bottom)
                }
            }
        }
    }
}
