//
//  WWMarkdownWebViewUI.swift
//  WWMarkdownWebViewUI
//
//  Created by William.Weng on 2026/6/17.
//

import SwiftUI
import WebKit

/// 將 WKWebView 包成 SwiftUI View，用來顯示 Markdown 內容
///
/// 內部透過本地 HTML template + JavaScript 將 Markdown 轉成 HTML，並把內容高度回傳給 SwiftUI，方便外部依照內容自動調整高度
public struct WWMarkdownWebViewUI {
    
    static let contentHeightName = "contentHeight"  // JavaScript 回傳內容高度時使用的 message handler 名稱
    
    let markdown: String
    
    @Binding var textStyle: TextStyle
    @Binding var height: CGFloat
    
    @State var manager = Manager()
    
    /// 建立 Markdown WebView
    ///
    /// - Parameters:
    ///   - markdown: 要渲染的 Markdown 字串
    ///   - dynamicHeight: WebView 實際內容高度，透過 Coordinator 回寫給 SwiftUI
    ///   - textStyle: 文字風格
    ///   - manager: WebView取值管理器
    public init(markdown: String, height: Binding<CGFloat>, textStyle: Binding<TextStyle> = .constant(.light), manager: Manager = .init()) {
        self.markdown = markdown
        self.manager = manager
        _textStyle = textStyle
        _height = height
    }
}

// MARK: - UIViewRepresentable
extension WWMarkdownWebViewUI: UIViewRepresentable {}
public extension WWMarkdownWebViewUI {

    /// 建立 Coordinator，負責承接 WKNavigationDelegate、WKScriptMessageHandler 等 UIKit / WebKit 事件
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    /// 建立並初始化 WKWebView
    ///
    /// 這裡只做一次性的建立工作，例如：
    /// - 建立 configuration
    /// - 註冊 JavaScript message handler
    /// - 設定 navigationDelegate
    /// - 載入初始 HTML template
    func makeUIView(context: Context) -> WKWebView {
        
        let webView = makeWebView(coordinator: context.coordinator)
        
        context.coordinator.webView = webView
        Task { @MainActor in manager.webView = webView }
        
        return webView
    }
    
    /// 當 SwiftUI 狀態更新時同步內容到既有的 WKWebView
    ///
    /// 這裡不重新建立 WebView，只更新顯示內容
    func updateUIView(_ webView: WKWebView, context: Context) {
        
        context.coordinator.parent = self
        context.coordinator.renderIfNeeded()
    }
}

// MARK: - Private
private extension WWMarkdownWebViewUI {
    
    /// 從 Swift Package 的 resource bundle 讀取 HTML template
    ///
    /// `Bundle.module` 是 Swift Package 存取資源的標準方式
    static func readHtmlTemplate() -> String? {
        
        guard let url = Bundle.module.url(forResource: "Markdown", withExtension: "html"),
              let html = try? String(contentsOf: url, encoding: .utf8)
        else {
            return nil
        }
        
        return html
    }
}

// MARK: - Private
private extension WWMarkdownWebViewUI {
    
    /// 建立 WKWebView 並完成基礎設定
    ///
    /// 這裡會：
    /// - 建立 WKUserContentController
    /// - 註冊 JavaScript message handler
    /// - 啟用 JavaScript
    /// - 關閉 WebView 自己的捲動，交由外層 SwiftUI 控制
    /// - 載入本地 HTML template
    func makeWebView(coordinator: Coordinator) -> WKWebView {
        
        let htmlTemplate = Self.readHtmlTemplate() ?? ""
        let contentController = WKUserContentController()
        let weakHandler = WeakScriptMessageHandler(delegate: coordinator)
        contentController.add(weakHandler, name: Self.contentHeightName)
        
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = contentController
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = coordinator
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.backgroundColor = .clear
        webView.loadHTMLString(htmlTemplate, baseURL: Bundle.module.resourceURL)
        
        return webView
    }
}
