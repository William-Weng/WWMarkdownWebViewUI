[English](./ReadMe.en.md) | [繁體中文](./ReadMe.md)

# [WWMarkdownWebViewUI](https://swiftpackageindex.com/William-Weng)

![SwiftUI](https://img.shields.io/badge/SwiftUI-524520?logo=swift)
[![Swift-5.7](https://img.shields.io/badge/Swift-5.7-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![iOS-16.0](https://img.shields.io/badge/iOS-16.0-pink.svg?style=flat)](https://developer.apple.com/swift/)
![TAG](https://img.shields.io/github/v/tag/William-Weng/WWMarkdownWebViewUI)
[![Swift Package Manager-SUCCESS](https://img.shields.io/badge/Swift_Package_Manager-SUCCESS-blue.svg?style=flat)](https://developer.apple.com/swift/)
[![LICENSE](https://img.shields.io/badge/LICENSE-MIT-yellow.svg?style=flat)](https://developer.apple.com/swift/)

A lightweight Swift Package that renders Markdown with `WKWebView` inside SwiftUI, supports dynamic height, and keeps the integration simple.

![WWMarkdownWebViewUI](https://github.com/user-attachments/assets/5a10b170-23a8-4da1-9742-053f1f6028ec)

## [✨ Features](https://peterpanswift.github.io/iphone-bezels/)

- Wraps `WKWebView` with `UIViewRepresentable` for SwiftUI usage.
- Renders Markdown through a bundled local `HTML` template loaded from `Bundle.module`.
- Sends rendered content height back to SwiftUI through `WKScriptMessageHandler` so the view can size itself to content.
- Uses a weak message-handler wrapper to reduce the retain-cycle risk commonly seen with `WKUserContentController.add(_:name:)`.
- Avoids repeated rendering by tracking page-ready state and the last rendered Markdown value.

## Installation

Add the package in Xcode with **File > Add Package Dependencies...** and point it to your repository URL.

Or add it to `Package.swift`:

```swift
.package(url: "https://github.com/William-Weng/WWMarkdownWebViewUI.git", from: "0.1.1")
```

Then add the product to your target dependencies:

```swift
dependencies: [
    .product(name: "WWMarkdownWebViewUI", package: "WWMarkdownWebViewUI")
]
```

## 🚀 Quick Start

```swift
import SwiftUI
import WWMarkdownWebViewUI

struct ContentView: View {

    @State private var height: CGFloat = 1

    let markdown = """
    # Hello

    This is **Markdown** rendered inside `WKWebView`.

    - Item 1
    - Item 2
    """

    var body: some View {
        WWMarkdownWebViewUI(markdown: markdown, dynamicHeight: $height)
            .frame(height: height)
    }
}
```

`dynamicHeight` should usually be bound to the outer frame so the SwiftUI layout follows the rendered web content height.

## ⚙️ How It Works

### 1. Create once, update many

The package follows the standard `UIViewRepresentable` lifecycle: `makeCoordinator()` creates the bridge object, `makeUIView(context:)` creates the `WKWebView`, and `updateUIView(_:context:)` pushes new state into the existing view.[cite:181][cite:168][cite:339]

### 2. Local HTML template

Markdown is rendered through a bundled `Markdown.html` resource loaded with `Bundle.module`, which is the recommended Swift Package resource access pattern.[cite:239][cite:260]

### 3. JavaScript bridge

The HTML page exposes `window.renderMarkdown(...)`, and native code calls it after the page finishes loading through `webView(_:didFinish:)`.[cite:321][cite:253]

### 4. Dynamic height

The web page posts its rendered height back through `window.webkit.messageHandlers.contentHeight.postMessage(...)`, and the coordinator writes that value back to the SwiftUI binding on the main actor.[cite:332][cite:274][cite:267]

## 🧩 Package Resources

Make sure the package target includes the HTML resource, for example:

```swift
.target(
    name: "WWMarkdownWebViewUI",
    resources: [
        .process("Resources")
    ]
)
```

Resources in Swift packages should be read from `Bundle.module`, not `Bundle.main`.

## 🧠 Design Notes

### Why `WKWebView`

SwiftUI does not provide a native, full Markdown renderer with the same flexibility as a custom HTML pipeline, so wrapping `WKWebView` remains a practical interoperability pattern for richer rendering needs.

### Why a coordinator

The coordinator acts as the bridge for `WKNavigationDelegate` and `WKScriptMessageHandler`, which is the standard role of a coordinator in `UIViewRepresentable` integrations.

### Why a weak message handler

`WKUserContentController` strongly retains its script message handler, so using a weak wrapper helps avoid common memory leaks and retain cycles.

## 📝 Notes

- The bundled HTML should keep `html` and `body` backgrounds transparent if the SwiftUI parent view is responsible for the final background styling.
- If the view appears taller than expected, verify that the outer SwiftUI container is using `dynamicHeight` correctly.
- If JavaScript updates appear to fail, confirm that rendering happens after `didFinish` and that the HTML defines `window.renderMarkdown`.

## Example HTML Contract

The package expects the bundled HTML to expose a function like this:

```javascript
window.renderMarkdown = function(markdown) {
  // render markdown into the page
}
```

And report height back to native code like this:

```javascript
window.webkit.messageHandlers.contentHeight.postMessage(height)
```
