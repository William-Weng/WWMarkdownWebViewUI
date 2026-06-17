//
//  TextStyle.swift
//  WWMarkdownWebViewUI
//
//  Created by William.Weng on 2026/6/17.
//

import Foundation

public extension WWMarkdownWebViewUI {
    
    enum TextStyle: Equatable {
        
        case light
        case dark
        case custom(color: String, size: Int)
        
        func script() -> String {

            switch self {
            case .light: return Self.makeScript(color: "#181A18", size: 17)
            case .dark: return Self.makeScript(color: "#f0f0f0", size: 17)
            case .custom(let color, let size): return Self.makeScript(color: color, size: size)
            }
        }
    }
}

private extension WWMarkdownWebViewUI.TextStyle {
    
    static func makeScript(color: String, size: Int) -> String {
        return "setTextStyle(\(color.jsQuoted), \(size))"
    }
}
