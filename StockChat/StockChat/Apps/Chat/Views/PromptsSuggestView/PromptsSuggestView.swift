//
//  PromptsSuggestView.swift
//  StockChat
//
//  Created by Macbook on 3/3/25.
//

import SwiftUI
import GeminiAI

struct PromptsSuggestView: View {
    
    var promptsSug: [PromptsSuggest]
    var actionTabPromptSuggest: (_ prompt: PromptsSuggest) -> Void
    
    var body: some View {
        VStack {
            ForEach(promptsSug, id: \.id) { prompt in
                
                Text(prompt.prompt)
                    .font(.caption)
                    .foregroundStyle(.white)
                    .padding(5)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                    .padding(.vertical, 5)
                    .padding(.leading, 30)
                    .onTapGesture {
                        actionTabPromptSuggest(prompt)
                        /*
                        Task {
                            let prt = prompt
                            chatVM.resetSuggestIdea()
                            onSendSuggest(prt.prompt)
                        }
                        */
                    }
                    .id(prompt.id)
            }
        }
    }
}
