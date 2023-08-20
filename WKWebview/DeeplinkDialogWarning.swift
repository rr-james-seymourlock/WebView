//
//  DeeplinkDialogWarning.swift
//  WKWebview
//
//  Created by James Seymour-Lock on 8/20/23.
//

import UIKit
import WebKit

class DeeplinkDialogWarning {

    let restrictedURLs: [String]
    let restrictedSchemes: [String]
    let whitelistURLs: [String]
    let whitelistSchemes: [String]

    init(restrictedURLs: [String], restrictedSchemes: [String], whitelistURLs: [String], whitelistSchemes: [String]) {
        self.restrictedURLs = restrictedURLs
        self.restrictedSchemes = restrictedSchemes
        self.whitelistURLs = whitelistURLs
        self.whitelistSchemes = whitelistSchemes
    }

    func matchesRestrictedPattern(url: URL, pattern: String, isWhitelist: Bool = false) -> Bool {

        // If the URL should be checked against the whitelist
        if isWhitelist {
            // Check if the URL's scheme is in the whitelist schemes.
            if whitelistSchemes.contains(url.scheme ?? "") {
                return true
            }
        }
        // If the URL should be checked against the restricted list
        else {
            // Check if the URL's scheme is in the restricted schemes.
            if restrictedSchemes.contains(url.scheme ?? "") {
                return true
            }
        }

        // Note: The above check for restricted schemes seems redundant with the check below.
        // Consider removing one for cleaner code.

        // Check against restricted schemes
        if restrictedSchemes.contains(url.scheme ?? "") {
            return true
        }

        // Handle wildcard domain matching (e.g., "*all.example.com" matches "sub.example.com")
        if pattern.hasPrefix("*all.") {
            let domainPart = pattern.replacingOccurrences(of: "*all.", with: "")
            // Generate a regex pattern to match subdomains of the specified domain
            let regexPattern = "^[^.]+\\.\(domainPart.replacingOccurrences(of: ".", with: "\\."))$"
            // If the URL's host matches the regex pattern, return true
            if let host = url.host, let _ = host.range(of: regexPattern, options: .regularExpression) {
                return true
            }
        }
        // Simple string match against the host of the URL
        else if let host = url.host, host.contains(pattern) {
            return true
        }

        return false
    }


    func shouldShowWarning(for url: URL) -> Bool {
        return restrictedURLs.contains { matchesRestrictedPattern(url: url, pattern: $0) }
    }

    func showWarning(for url: URL, webView: WKWebView, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let alert = UIAlertController(title: "Leaving Rakuten? You'll miss out on Cash Back.",
                                      message: "Do you really want to visit \(url.host ?? "this site")?",
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Keep shopping with Rakuten",
                                      style: .cancel,
                                      handler: { _ in
                                          decisionHandler(.cancel)
                                      }))

        alert.addAction(UIAlertAction(title: "Leave Rakuten",
                                      style: .default,
                                      handler: { _ in
                                          decisionHandler(.allow)
                                      }))

        if let viewController = webView.window?.rootViewController {
            viewController.present(alert, animated: true)
        }
    }
}

