//
//  Extension.swift
//  WWMarkdownWebViewUI
//
//  Created by William.Weng on 2026/6/17.
//

import Foundation

extension String {
    
    var jsQuoted: String {
        
        let escaped = self
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "'", with: "\\'")
            .replacingOccurrences(of: "\n", with: "\\n")
            .replacingOccurrences(of: "\r", with: "\\r")
        
        return "'\(escaped)'"
    }
}
