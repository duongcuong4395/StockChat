//
//  ChatViewModel.swift
//  StockChat
//
//  Created by Macbook on 3/3/25.
//

import SwiftUI
import GeminiAI
import GoogleGenerativeAI



class ChatViewModel: ObservableObject {
    var chat: Chat?
    @Published var inputText: String = ""
    @Published var history: [ModelContent] = []
    @Published var messages: [ChatMessage] = []
    @Published var imagesSelected: [UIImage] = []
    @Published var promptsSuggest: [String] = []
    
    // More
    @Published var promptsSug: [PromptsSuggest] = []
    @Published var currentTrading: Trading = .StockMarket
}

extension ChatViewModel: AIChatEvent {
    
    func getKey() -> GeminiAI.GeminiAIModel {
        return .init(itemKey: "key", valueItem: "AIzaSyCp1xQLOzjLgFPHg31hqhJ2yWFSa1d_W1M")
    }
    
    func eventFrom(aiResponse: GeminiAI.ChatMessage) {
        return
    }
    
}

extension ChatViewModel {
    
    func resetHistory() {
        withAnimation(.spring()) {
            chat?.history = []
            messages = []
            promptsSug = []
        }
    }
    
    func remove(image: UIImage) {
        self.imagesSelected.removeAll(where: { $0 == image })
    }
}

// MARK: Chat/Send messasge
extension ChatViewModel {
    func chat(by owner: RequestBy, with prompt: String
              , and images: [UIImage] = []
              , has stream: Bool = false
              , of versionAI: GeminiAIVersion = .gemini_2_0_flash_exp) async throws {
        
        if owner == .Client {
            clientSend(with: prompt, and: images)
        }
        
        if images.count > 0 {
            try await aiResponse(with: prompt, and: images, has: stream, of: versionAI)
        } else {
            await aiResponse(with: prompt, has: stream)
        }
    }
}

// MARK: Add and Update Message
extension ChatViewModel {
    func add(_ message: ChatMessage) {
        DispatchQueue.main.async{ [weak self] in
            withAnimation {
                self?.messages.append(contentsOf: [message])
                self?.inputText = ""
                self?.imagesSelected = []
            }
        }
    }
    
    func update(message: ChatMessage, by content: String) {
        if let index = self.messages.firstIndex(where: { $0.id == message.id }) {
            DispatchQueue.main.async{ [weak self] in
                self?.messages[index].content = content
            }
        }
        
    }
    
    func addChatHistory(by message: ChatMessage) {
        if let index = self.messages.firstIndex(where: { $0.id == message.id }) {
            DispatchQueue.main.async{ [weak self] in
                if let md = self?.messages[index] {
                    self?.chat?.history.append(md.toModelContent())
                }
            }
        }
    }
}

extension ChatViewModel {
    // MARK: Send Text
    func aiSendSuggestIdea() async {
        guard let chat = chat else { return }
        
        let prompt: String = """
        từ hình ảnh và thông tin đó hãy list ra cho tôi một mảng 5 prompts gợi ý(List of Prompts for suggest) mà tôi có thể hỏi bạn để có thể đầu tư chứng khoán một cách khôn ngoan và ít rủi ro nhất. bạn chỉ cần trả về cho tôi Theo mẫu sau mà không cần nói gì thêm: ["prompt", "prompt"]
        """

        do {
            let response = try await chat.sendMessage(prompt)
            print("=== response.text", response.text ?? "") // Output: ["prompt 1", "prompt2"]
            let aiMessage = ChatMessage(content: response.text ?? "", isUser: false)

            let jsonString = aiMessage.content
            if let jsonData = jsonString.data(using: .utf8) {
                do {
                    let prompts = try JSONDecoder().decode([String].self, from: jsonData)
                    DispatchQueue.main.async{
                        self.promptsSuggest = prompts
                        self.promptsSug = prompts
                            .prefix(3)
                            .map{ PromptsSuggest(prompt: $0) }
                    }
                    
                } catch {
                    print("Lỗi parse JSON: \(error)")
                    DispatchQueue.main.async{
                        self.promptsSuggest = []
                        self.promptsSug = []
                    }
                }
            }

        } catch {
            print("Error sending message: \(error)")
        }
    }
    
    func resetSuggestIdea() {
        withAnimation {
            DispatchQueue.main.async{
                self.promptsSuggest = []
            }
        }
    }
}
