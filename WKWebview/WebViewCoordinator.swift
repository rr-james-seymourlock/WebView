//
//  WebViewCoordinator.swift
//  WKWebview
//
//  Created by James Seymour-Lock on 8/19/23.
//

import WebKit

extension WebView {
    /// Coordinator acts as a delegate for `WKWebView` to handle navigation events.
    class Coordinator: NSObject, WKNavigationDelegate {

        /// A reference to the parent `WebView` to access its properties.
        var parent: WebView

        init(_ parent: WebView) {
            self.parent = parent
        }
    }
}
