//
//  WebViewNavigation.swift
//  WKWebview
//
//  Created by James Seymour-Lock on 8/19/23.
//

// WebViewNavigation.swift

import WebKit

extension WebView.Coordinator {

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }

        if navigationAction.targetFrame?.isMainFrame ?? false && url.absoluteString != "about:blank" {
            if !parent.loadedURLs.contains(url) {
                parent.loadedURLs.append(url)
            }
        }

        if parent.whitelistURLs.contains(where: { parent.deeplinkDialogWarning.matchesRestrictedPattern(url: url, pattern: $0) })
        || parent.whitelistSchemes.contains(url.scheme ?? "") {
            decisionHandler(.allow)
            return
        }

        if parent.deeplinkDialogWarning.shouldShowWarning(for: url) {
            parent.deeplinkDialogWarning.showWarning(for: url, webView: webView, decisionHandler: decisionHandler)
        } else {
            decisionHandler(.allow)
        }
    }
}
