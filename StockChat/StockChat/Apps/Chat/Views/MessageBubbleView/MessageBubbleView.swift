//
//  MessageBubbleView.swift
//  StockChat
//
//  Created by Macbook on 3/3/25.
//

import SwiftUI
import GeminiAI

struct MessageBubbleView: View {
    let message: ChatMessage
    
    var showImageFromClient: Bool = true
    @State private var animatedText: String = ""
    
    var body: some View {
        HStack(alignment: .top) {
            if message.isUser {
                Spacer()
                Spacer()
                VStack {
                    if showImageFromClient {
                        HStack {
                            Spacer()
                            ForEach(message.swiftUIImages, id: \.id) { image in
                                image.image
                                    .resizable()
                                    .frame(width: 100, height: 100)
                            }
                        }
                    }
                    
                    Text(message.content)
                        .font(.caption)
                        .frame(alignment: .trailing)
                }
                .padding(5)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            } else {
                if message.content.isEmpty {
                    HStack {
                        Text("Phân tích kỹ thuật và cơ bản về cổ phiếu XYZ (ví dụ: VNM, HPG) như thế nào, và những yếu tố nào cho thấy tiềm năng tăng trưởng dài hạn?\", \"Chiến lược đa dạng hóa danh mục đầu tư nào phù hợp cho người mới bắt đầu với mức vốn [X] triệu đồng, và tỷ lệ phân bổ vào các loại tài sản khác nhau nên là bao nhiêu?\", \"Rủi ro lớn nhất khi đầu tư vào ngành [X]")
                            .font(.caption)
                        //+ Text("... More").font(.caption.bold())
                    }
                    .redacted(reason: .placeholder)
                    
                        
                } else {
                    Text(message.localizedContent)
                        .font(.caption)
                        .padding(5)
                        .background(.ultraThinMaterial.opacity(message.isUser ? 1 : 0), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
                
                Spacer()
                Spacer()
            }
        }
        .foregroundStyle(.white)
        .padding(.leading, message.isUser ? 30 : 0)
        .padding(.trailing, message.isUser ? 0 : 30)
    }
    
    // 🔥 Hàm tạo hiệu ứng gõ chữ 🔥
    private func startTypingEffect() {
        animatedText = ""
        let characters = Array(message.content)
        var index = 0

        Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { timer in
            if index < characters.count {
                animatedText.append(characters[index])
                index += 1
            } else {
                timer.invalidate() // Dừng khi hoàn thành
            }
        }
    }
}
