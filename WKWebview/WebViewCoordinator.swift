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

        let global = "#branch-banner-iframe, #branch-banner, .branch-banner-content { display: none; }"
        let nike = "body > #singular-banner.bottom { display: none; }"
        let removeAppBannerStyles: [String]

        init(_ parent: WebView) {
            self.parent = parent
            removeAppBannerStyles = [global, nike]
        }
        func injectCSS(_ webView: WKWebView, css: String) {
            guard let jsonCSS = try? JSONSerialization.jsonObject(with: css.data(using: .utf8)!, options: .fragmentsAllowed) as? String else {
                print("Failed to serialize CSS")
                return
            }

            let jsString = """
                var style = document.createElement('style');
                style.innerHTML = '\(jsonCSS)';
                document.head.appendChild(style);
            """

            webView.evaluateJavaScript(jsString) { (result, error) in
                if let error = error {
                    print("Failed to inject CSS with error: \(error.localizedDescription)")
                } else {
                    print("CSS injected successfully")
                }
            }
        }

        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            let cssString = parent.cssToInject.joined(separator: " ")
            let js = """
            var style = document.createElement('style');
            style.type = 'text/css';
            style.innerHTML = '\(cssString)';
            document.head.appendChild(style);
            """
            webView.evaluateJavaScript(js, completionHandler: nil)
        }
    }
    
}
