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
    # Hello

    這是一段顯示在 `WKWebView` 裡的 **Markdown**。
    
    - Item 1
    - Item 2
    """

    var body: some View {
        WWMarkdownWebViewUI(markdown: markdown, dynamicHeight: $height)
            .frame(height: height)
    }
}

#Preview {
    ContentView()
}
