//
//  ImagesSelectedView.swift
//  StockChat
//
//  Created by Macbook on 3/3/25.
//

import SwiftUI

struct ChatImagesSelectedView: View {
    
    var imagesSelected: [UIImage]
    
    var removeImageSelected: (_ image: UIImage) -> Void
    
    var body: some View {
        HStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 5) {
                    
                    ForEach(imagesSelected, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 50)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                            .overlay {
                                VStack {
                                    HStack{
                                        Spacer()
                                        Image(systemName: "xmark")
                                            .font(.caption2)
                                            .padding(5)
                                            .background(.ultraThinMaterial, in: Circle())
                                            .onTapGesture {
                                                removeImageSelected(image)
                                                /*
                                                withAnimation {
                                                    chatVM.remove(image: image)
                                                }
                                                 */
                                            }
                                            .overlay {
                                                Circle()
                                                    .strokeBorder(Color.white,lineWidth: 1)
                                            }
                                            
                                    }
                                    Spacer()
                                    
                                }
                            }
                            .padding(10)
                            
                    }
                }
            }
        }
    }
}
