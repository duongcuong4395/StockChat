//
//  AppUtilities.swift
//  StockChat
//
//  Created by Macbook on 3/3/25.
//


import SwiftUI
import WebKit
import Photos
class AppUtilities {
    static func takeScreenshot(from webView: WKWebView,_ completion: @escaping (UIImage?) -> Void) {
        webView.takeSnapshot(with: nil) { image, error in
            /*
            if let image = image {
                capturedImage = image
                saveImageToGallery(image)
            }
            */
            completion(image)
        }
    }
    
    static func saveImageToGallery(_ image: UIImage) {
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized || status == .limited {
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            } else {
                print("❌ Không có quyền lưu ảnh vào bộ sưu tập")
            }
        }
    }
}
