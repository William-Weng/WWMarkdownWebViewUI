//
//  Coordinator.swift
//  WWMarkdownWebViewUI
//
//  Created by William.Weng on 2026/6/17.
//

import WebKit

// MARK: - WWMarkdownWebViewUI
public extension WWMarkdownWebViewUI {
    
    /// Coordinator 是 SwiftUI 與 WKWebView 之間的橋樑
    ///
    /// 主要負責：
    /// - 接收 WebView delegate 事件
    /// - 接收 JavaScript 傳回的訊息
    /// - 將事件結果同步回 SwiftUI 狀態
    final class Coordinator: NSObject {
        
        var parent: WWMarkdownWebViewUI         // 最新的父層 representable 狀態 => 會在 `updateUIView` 時同步更新，避免持有舊的 struct 值
        weak var webView: WKWebView?            // 對 WKWebView 的弱參考，避免不必要的強參考循環
        
        var isPageLoaded = false                // 頁面是否已完成初始載入 => 只有在頁面 ready 後，才可安全呼叫頁面內的 JavaScript 函式
        var lastRenderedMarkdown: String?       // 上一次成功渲染的 Markdown 內容 => 用來避免重複對相同內容進行 render
        var lastRenderedTextStyle: TextStyle?
        
        init(_ parent: WWMarkdownWebViewUI) {
            self.parent = parent
        }
    }
}

extension WWMarkdownWebViewUI.Coordinator: WKNavigationDelegate, WKScriptMessageHandler {}

// MARK: - WKNavigationDelegate
public extension WWMarkdownWebViewUI.Coordinator {
    
    /// 當 HTML template 載入完成後，呼叫頁面內的 `renderMarkdown(...)`，將目前的 Markdown 字串交給 JavaScript 進行渲染
    ///
    /// 之所以放在 `didFinish`，是因為必須等頁面完成載入後，頁面中的 JavaScript 函式才可安全呼叫
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        isPageLoaded = true
        renderIfNeeded(force: true)
    }
}

// MARK: - WKNavigationDelegate, WKScriptMessageHandler
public extension WWMarkdownWebViewUI.Coordinator {
        
    /// 接收 JavaScript 透過 `window.webkit.messageHandlers...postMessage(...)` 傳回的資料
    ///
    /// 這裡主要用來接收網頁實際內容高度，並回寫到 SwiftUI 的 `dynamicHeight`，讓外層可以依內容自動調整 WebView 高度
    ///
    /// 由於 SwiftUI / UIKit 的畫面狀態更新應在主執行緒進行，這裡使用 `@MainActor` 切回主執行緒更新資料
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        guard message.name == WWMarkdownWebViewUI.contentHeightName else { return }

        Task { @MainActor in
            
            if let height = message.body as? CGFloat { self.parent.height = height; return }
            if let height = message.body as? Double { self.parent.height = height; return }
            if let height = message.body as? Int { self.parent.height = CGFloat(height); return }
        }
    }
}

// MARK: - Public
extension WWMarkdownWebViewUI.Coordinator {
    
    /// 在頁面已載入完成的前提下，將目前的 Markdown 傳給 WebView 進行渲染
    ///
    /// 這個方法會檢查：
    /// - 頁面是否已 ready
    /// - WebView 是否仍存在
    /// - Markdown 是否真的有變化
    ///
    /// 若 `force == true`，則即使內容未變動，也會強制重新渲染一次
    func renderIfNeeded(force: Bool = false) {
        
        guard isPageLoaded,
              let webView
        else {
            return
        }
        
        let markdown = parent.markdown
        let textStyle = parent.textStyle
        
        guard force || (markdown != lastRenderedMarkdown) || (textStyle != lastRenderedTextStyle) else { return }
        guard let payload = Self.makeJSONArgument(markdown) else { return }
        
        let js = """
        \(textStyle.script);
        window.renderMarkdown(\(payload));
        """
        
        webView.evaluateJavaScript(js)
        lastRenderedMarkdown = markdown
        lastRenderedTextStyle = textStyle
    }
}

// MARK: - Private
private extension WWMarkdownWebViewUI.Coordinator {
        
    /// 將 Swift 字串轉成可安全嵌入 JavaScript 的 JSON 字串字面值
    ///
    /// 這樣可避免手動跳脫引號、反斜線、換行等特殊字元，降低字串注入或語法破壞的風險
    ///
    /// 例如：
    /// - 原始字串：`Hello "Swift"\nWorld`
    /// - 輸出結果：`"Hello \"Swift\"\nWorld"`
    ///
    /// 這裡透過先將字串包成陣列做 JSON 序列化，再去掉外層 `[` 與 `]`，取得單一字串的 JSON 字面值
    static func makeJSONArgument(_ value: String) -> String? {
        
        guard let data = try? JSONSerialization.data(withJSONObject: [value], options: []),
              let json = String(data: data, encoding: .utf8)
        else {
            return nil
        }
        
        guard json.count >= 2 else { return nil }
        return String(json.dropFirst().dropLast())
    }
}
