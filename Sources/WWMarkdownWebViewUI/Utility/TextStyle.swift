//
//  TextStyle.swift
//  WWMarkdownWebViewUI
//
//  Created by William.Weng on 2026/6/17.
//

import Foundation

// MARK: - WWMarkdownWebViewUI.TextStyle
public extension WWMarkdownWebViewUI {
    
    // 定義 Markdown WebView 文字樣式，用來決定文字顏色與大小
    enum TextStyle: Equatable {
        
        case light                              // 淺色模式：偏深色文字，搭配淺底使用
        case dark                               // 深色模式：偏淺色文字，搭配深底使用
        case custom(color: String, size: Int)   // 自訂樣式：可自行指定文字顏色與字級大小
    }
}

// MARK: - Script Builder
public extension WWMarkdownWebViewUI.TextStyle {
    
    /// 將 TextStyle 轉成可執行的 JavaScript 字串
    var script: String {

        switch self {
        case .light: return Self.makeScript(color: "#181A18", size: 17)
        case .dark: return Self.makeScript(color: "#f0f0f0", size: 17)
        case .custom(let color, let size): return Self.makeScript(color: color, size: size)
        }
    }
}

// MARK: - Private Helpers
private extension WWMarkdownWebViewUI.TextStyle {
    
    /// 組合 JavaScript 呼叫字串，避免重複撰寫
    static func makeScript(color: String, size: Int) -> String {
        return "setTextStyle(\(color.jsQuoted), \(size))"
    }
}
