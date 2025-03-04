//
//  ChatView.swift
//  StockChat
//
//  Created by Macbook on 3/3/25.
//

import SwiftUI
import GeminiAI
import GoogleGenerativeAI


struct ChatView: View {
    var aiChatEvent: AIChatEvent
    @Binding var inputText: String
    @State private var sending: Bool = false
    var onSendPromptSuggest: (String) -> Void
    var removeImageSelected: (_ image: UIImage) -> Void
    var onSend: () -> Void
    var body: some View {
        VStack {
            ChatHistoryView(messages: aiChatEvent.messages
                            , promptsSuggest: aiChatEvent.promptsSug
                            , resetPromptSuggest: {
                aiChatEvent.resetSuggestIdea()
            }, sendPromptSuggest: { promptSuggest in
                onSendPromptSuggest(promptSuggest.prompt)
            })
            
            if aiChatEvent.imagesSelected.count > 0 {
                ChatImagesSelectedView(imagesSelected: aiChatEvent.imagesSelected
                                       , removeImageSelected: removeImageSelected)
            }
            
            ChatSendPromptView(inputText: $inputText, sending: $sending, onSend: onSend)
        }
    }
}

struct ChatView2: View {
    @EnvironmentObject var chatVM: ChatViewModel
    
    
    @State private var sending: Bool = false
    var onSendPromptSuggest: (String) -> Void
    var removeImageSelected: (_ image: UIImage) -> Void
    var onSend: () -> Void
    var body: some View {
        VStack {
            ChatHistoryView(messages: chatVM.messages
                            , promptsSuggest: chatVM.promptsSug
                            , resetPromptSuggest: {
                chatVM.resetSuggestIdea()
            }, sendPromptSuggest: { promptSuggest in
                onSendPromptSuggest(promptSuggest.prompt)
            })
            
            if chatVM.imagesSelected.count > 0 {
                ChatImagesSelectedView(imagesSelected: chatVM.imagesSelected
                                       , removeImageSelected: removeImageSelected)
            }
            
            ChatSendPromptView(inputText: $chatVM.inputText, sending: $sending, onSend: onSend)
        }
    }
}




struct ChatSendPromptView: View {
    @Binding var inputText: String
    @Binding var sending: Bool
    @State var showListImagePicker: Bool = false
    
    var onSend: () -> Void
    var body: some View {
        HStack {
            TextField("Type a message...", text: $inputText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .disabled(sending)
            
            Button(action: {
                showListImagePicker.toggle()
            }) {
                Image(systemName: "photo.artframe")
                    .font(.title2)
            }
            .padding(10)
            
            Button(action: {
                onSend()
                /*
                Task {
                    isSending = true
                    onSend()
                    isSending = false
                }
                */
            }) {
                Image(systemName: "paperplane.fill")
                    .font(.title2)
            }
            .padding(10)
            .disabled(inputText.isEmpty || sending)
        }
    }
}
