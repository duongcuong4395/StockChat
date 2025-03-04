//
//  StockView.swift
//  StockChat
//
//  Created by Macbook on 3/3/25.
//

import SwiftUI
import WebKit
import WebView


enum Trading: String, CaseIterable {
    case StockMarket = "Stock market"
    case Crypto = "Crypto" // Cryptocurrencies
    case Currencies = "Currencies"
    case Commodities = "Commodities"
    case NYSEShares = "NYSE Shares"
    case NASDAQShares = "NASDAQ Shares"
    case EUShares = "EU Shares"
    case HKEXShares = "HKEX Shares"
    case StockIndices = "Stock Indices"
    
    
    var url: String {
        switch self {
        case .StockMarket:
            "https://iboard.ssi.com.vn/"
        case .Crypto:
            "https://my.litefinance.vn/trading?type=crypto"
        case .Currencies:
            "https://my.litefinance.vn/trading?type=currency"
        case .Commodities:
            "https://my.litefinance.vn/trading?type=commodities"
        case .NYSEShares:
            "https://my.litefinance.vn/trading?type=cfd-nyse"
        case .NASDAQShares:
            "https://my.litefinance.vn/trading?type=cfd-nasdaq"
        case .EUShares:
            "https://my.litefinance.vn/trading?type=cfd-eu"
        case .HKEXShares:
            "https://my.litefinance.vn/trading?type=cfd-hkex"
        case .StockIndices:
            "https://my.litefinance.vn/trading?type=index"
        }
    }
}


struct StockWebView: View {
    @Binding var webView: WKWebView
    // @State private var webView = WKWebView()
    @Binding var webLoading: Bool
    //@State var currentTrading: Trading = .StockMarket
    @Binding var currentTrading: Trading
    
    var onChangeTrading: () -> Void
    
    var body: some View {
        VStack {
            ListTradingView
                .padding(.leading, 60)
            // WebControlView
            //ZStack {}
            WebView(webView: $webView, isLoading: $webLoading, url: URL(string: currentTrading.url)!)
                .edgesIgnoringSafeArea(.all)
                .overlay {
                    LoadingWebView
                }
        }
        
    }
    
    @ViewBuilder
    var ListTradingView: some View {
        HStack{
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(Trading.allCases, id: \.self) { trade in
                        Text(trade.rawValue)
                            .font(trade == currentTrading ? .caption.bold() : .caption)
                            .padding(5)
                            .background(.ultraThinMaterial.opacity(trade == currentTrading ? 1 : 0), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                            .padding(5)
                            .onTapGesture {
                                withAnimation {
                                    
                                    let curr = currentTrading
                                    currentTrading = trade
                                    loadNewURL(URL(string: currentTrading.url)!)
                                    if curr != trade {
                                        onChangeTrading()
                                    }
                                    /*
                                    if curr != trade {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                            chatVM.resetHistory()
                                            startChat()
                                        }
                                    }
                                    */
                                }
                            }
                    }
                }
                .foregroundStyle(.white)
            }
        }
    }
    
    @ViewBuilder
    var WebControlView: some View {
        // Thanh công cụ điều hướng
        if !webLoading {
            HStack {
                Button(action: goBack) {
                    Image(systemName: "chevron.left")
                }
                .disabled(!webView.canGoBack)

                Button(action: goForward) {
                    Image(systemName: "chevron.right")
                }
                .disabled(!webView.canGoForward)

                Button(action: reload) {
                    Image(systemName: "arrow.clockwise")
                }

                Button(action: stopLoading) {
                    Image(systemName: "xmark")
                }
                .disabled(!webLoading)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
        }
    }
    
    @ViewBuilder
    var LoadingWebView: some View {
        if webLoading {
            ProgressView("Loading...")
                .progressViewStyle(CircularProgressViewStyle())
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white.opacity(0.5))
        }
    }
    
    // Khi URL thay đổi, load lại trang mới
    private func loadNewURL(_ newURL: URL) {
        let request = URLRequest(url: newURL)
        webView.load(request)
    }

    // Các hàm điều khiển WebView
    private func goBack() {
        if webView.canGoBack { webView.goBack() }
    }

    private func goForward() {
        if webView.canGoForward { webView.goForward() }
    }

    private func reload() {
        webView.reload()
    }

    private func stopLoading() {
        webView.stopLoading()
    }
}
