//
//  Manager.swift
//  WWMarkdownWebViewUI
//
//  Created by William.Weng on 2026/6/18.
//

import SwiftUI
import WebKit

// 管理 WebView 和 JS 結果的 ObservableObject
public extension WWMarkdownWebViewUI {
    
    final class Manager: ObservableObject {
        
        @Published public var webView: WKWebView?
        
        public init() {}
    }
}

// MARK: - Public
public extension WWMarkdownWebViewUI.Manager {
    
    // Swift 呼叫 JS 取得文字
    @MainActor
    func getTextContent() async throws -> String? {
        
        guard let webView = webView else { return nil }
        
        let result = await try webView.evaluateJavaScript("getTextContent()")
        return result as? String
    }
    
    // Swift 呼叫 JS 取得 HTML
    @MainActor
    func getHtmlContent() async throws -> String? {
        
        guard let webView = webView else { return nil }
        
        let result = await try webView.evaluateJavaScript("getHtmlContent()")
        return result as? String
    }
}
