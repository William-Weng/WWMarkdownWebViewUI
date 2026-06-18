[English](./ReadMe.en.md) | [繁體中文](./ReadMe.md)

# [WWMarkdownWebViewUI](https://swiftpackageindex.com/William-Weng)

![SwiftUI](https://img.shields.io/badge/SwiftUI-524520?logo=swift)
[![Swift-5.7](https://img.shields.io/badge/Swift-5.7-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![iOS-16.0](https://img.shields.io/badge/iOS-16.0-pink.svg?style=flat)](https://developer.apple.com/swift/)
![TAG](https://img.shields.io/github/v/tag/William-Weng/WWMarkdownWebViewUI)
[![Swift Package Manager-SUCCESS](https://img.shields.io/badge/Swift_Package_Manager-SUCCESS-blue.svg?style=flat)](https://developer.apple.com/swift/)
[![LICENSE](https://img.shields.io/badge/LICENSE-MIT-yellow.svg?style=flat)](https://developer.apple.com/swift/)

一個輕量級的 Swift Package，使用 `WKWebView` 在 SwiftUI 中渲染 Markdown，支援動態高度，並盡量維持整合簡潔。

![WWMarkdownWebViewUI](https://github.com/user-attachments/assets/9177518a-a1b3-4129-b05b-a1dc435571c9)

## ✨ [功能特色](https://peterpanswift.github.io/iphone-bezels/)

- 透過 `UIViewRepresentable` 將 `WKWebView` 包裝成 SwiftUI View。
- 透過套件內建的本地 `HTML` 模板渲染 Markdown，並從 `Bundle.module` 讀取資源。
- 透過 `WKScriptMessageHandler` 將渲染後的內容高度回傳給 SwiftUI，讓外層可依內容自動調整高度。
- 使用弱引用的 message handler wrapper，降低 `WKUserContentController.add(_:name:)` 常見的 retain cycle 風險。
- 透過頁面 ready 狀態與上一次 Markdown 內容，避免重複渲染。

## 📦 安裝方式

在 Xcode 中選擇 **File > Add Package Dependencies...**，輸入你的 repository URL 即可加入套件。

或者加入到 `Package.swift`：

```swift
.package(url: "https://github.com/William-Weng/WWMarkdownWebViewUI.git", from: "0.3.0")
```

然後把產品加入 target dependencies：

```swift
dependencies: [
    .product(name: "WWMarkdownWebViewUI", package: "WWMarkdownWebViewUI")
]
```

## 🚀 快速開始

```swift
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
        WWMarkdownWebViewUI(markdown: markdown, dynamicHeight: $height)
            .frame(height: height)
    }
}
```

`dynamicHeight` 通常會綁定外層 frame，讓 SwiftUI 版面跟著網頁實際內容高度調整。

## ⚙️ 運作方式

### 1. 先建立，後更新

這個套件遵循標準的 `UIViewRepresentable` 生命週期：`makeCoordinator()` 建立橋樑物件，`makeUIView(context:)` 建立 `WKWebView`，`updateUIView(_:context:)` 則把新的狀態同步到既有的 view。

### 2. 本地 HTML 模板

Markdown 透過套件內的 `Markdown.html` 資源來渲染，並使用 `Bundle.module` 載入，這是 Swift Package 存取資源的標準方式。

### 3. JavaScript 溝通橋接

HTML 頁面會提供 `window.renderMarkdown(...)`，native 端在頁面載入完成後透過 `webView(_:didFinish:)` 呼叫它。

### 4. 動態高度

網頁會透過 `window.webkit.messageHandlers.contentHeight.postMessage(...)` 回傳實際高度，而 coordinator 會在主執行緒把這個值寫回 SwiftUI binding。

## 🧩 資源設定

請確認 package target 有把 HTML 加入 resource，例如：

```swift
.target(
    name: "WWMarkdownWebViewUI",
    resources: [
        .process("Resources")
    ]
)
```

Swift Package 的資源應該從 `Bundle.module` 讀取，而不是 `Bundle.main`。

## 🧠 設計說明

### 為什麼用 `WKWebView`

SwiftUI 目前沒有原生提供同等彈性的 Markdown 渲染管線，因此用 `WKWebView` 包裝 HTML 仍然是實務上很常見、也很靈活的做法。

### 為什麼需要 Coordinator

Coordinator 負責接 `WKNavigationDelegate` 和 `WKScriptMessageHandler`，也就是 `UIViewRepresentable` 裡標準的橋接角色。

### 為什麼要用弱引用 message handler

`WKUserContentController` 會強引用 script message handler，因此使用 weak wrapper 可以降低常見的記憶體洩漏與循環參考問題。

## 📝 注意事項

- 如果 SwiftUI 外層要控制背景，建議 HTML 的 `html` 與 `body` 保持透明背景。
- 如果 view 看起來比預期高，請檢查外層是否正確使用 `dynamicHeight`。
- 如果 JavaScript 更新沒有生效，請確認渲染是在 `didFinish` 之後，且 HTML 內有定義 `window.renderMarkdown`。

## HTML 介面契約

這個套件預期 HTML 內有類似下面的函式：

```javascript
window.renderMarkdown = function(markdown) {
  // render markdown into the page
}
```

並且回傳高度給 native 端：

```javascript
window.webkit.messageHandlers.contentHeight.postMessage(height)
```

