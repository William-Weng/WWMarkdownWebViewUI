//
//  WeakScriptMessageHandler.swift
//  WWMarkdownWebViewUI
//
//  Created by William.Weng on 2026/6/17.
//

import WebKit

/// `WKUserContentController` 會強引用加入的 `WKScriptMessageHandler`。
///
/// 若直接把 `Coordinator` 或 `self` 加進去，可能形成 retain cycle，進而導致 `WKWebView` 或外層物件無法正常釋放。
///
/// 這個類別作為中介層：
/// - 由 WebKit 強引用這個 wrapper
/// - wrapper 只用 weak 方式持有真正的 delegate
/// - 收到 JavaScript 訊息後，再轉送給真正的 handler
///
/// 這是一種常見的 weak proxy / weak wrapper 寫法，用來避免 `WKScriptMessageHandler` 造成的記憶體洩漏問題
final class WeakScriptMessageHandler: NSObject, WKScriptMessageHandler {
    
    weak var delegate: WKScriptMessageHandler?
    
    /// 建立一個弱引用包裝器
    /// - Parameter delegate: 真正處理 JavaScript 訊息的對象 => 使用 weak 參考，避免形成強參考循環
    init(delegate: WKScriptMessageHandler) {
        self.delegate = delegate
    }
    
    /// 接收來自 JavaScript 的訊息，並轉送給真正的 delegate
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        delegate?.userContentController(userContentController, didReceive: message)
    }
}
