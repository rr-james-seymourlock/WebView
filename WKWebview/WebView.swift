//
//  WebView.swift
//  WKWebview
//
//  Created by James Seymour-Lock on 8/19/23.
//

import SwiftUI
import WebKit

/// `WebView` represents a web view within SwiftUI, allowing for browsing of web content.
/// This view will restrict or allow certain URLs or schemes based on provided whitelists and blacklists.
struct WebView: UIViewRepresentable {

    /// The current URL the WebView should display.
    @Binding var currentURL: URL

    /// The initial URL to load when the WebView is first created.
    let initialURL: URL

    /// List of restricted URLs that the user shouldn't navigate to without a prompt.
    let restrictedURLs: [String]

    /// List of restricted schemes that the user shouldn't navigate to without a prompt.
    let restrictedSchemes: [String]

    /// List of whitelisted URLs that the user can navigate to freely.
    let whitelistURLs: [String]

    /// List of whitelisted schemes that the user can navigate to freely.
    let whitelistSchemes: [String]

    /// CSS for banner removal
    let cssToInject: [String]

    /// A binding to a list of URLs that have been loaded.
    @Binding var loadedURLs: [URL]

    // Initialize DeeplinkDialogWarning class
    lazy var deeplinkDialogWarning: DeeplinkDialogWarning = {
        return DeeplinkDialogWarning(
            restrictedURLs: restrictedURLs,
            restrictedSchemes: restrictedSchemes,
            whitelistURLs: whitelistURLs,
            whitelistSchemes: whitelistSchemes
        )
    }()

    /// Creates a coordinator instance for the WebView.
    /// The coordinator acts as a delegate to handle navigation events.
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.load(URLRequest(url: currentURL))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        if uiView.url != currentURL {
            uiView.load(URLRequest(url: currentURL))
        }
    }
}
