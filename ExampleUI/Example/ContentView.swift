//
//  ContentView.swift
//  Example
//
//  Created by William.Weng on 2026/6/17.
//

import SwiftUI
import WWMarkdownWebViewUI

struct ContentView: View {

    @State private var height: CGFloat = 1

    let markdown = """
    # WWMarkdownWebViewUI
    一個輕量級的 Swift Package，使用 `WKWebView` 在 SwiftUI 中渲染 Markdown，支援動態高度，並盡量維持整合簡潔。
    
    ## ✨ [功能特色](https://peterpanswift.github.io/iphone-bezels/)

    1. 透過 `UIViewRepresentable` 將 `WKWebView` 包裝成 SwiftUI View。
    1. 透過套件內建的本地 `HTML` 模板渲染 Markdown，並從 `Bundle.module` 讀取資源。
    1. 透過 `WKScriptMessageHandler` 將渲染後的內容高度回傳給 SwiftUI，讓外層可依內容自動調整高度。
    1. 使用弱引用的 message handler wrapper，降低 `WKUserContentController.add(_:name:)` 常見的 retain cycle 風險。
    1. 透過頁面 ready 狀態與上一次 Markdown 內容，避免重複渲染。
    """

    var body: some View {
        WWMarkdownWebViewUI(markdown: markdown, height: $height)
            .frame(height: height)
            .padding(16)
    }
}

#Preview {
    ContentView()
}
