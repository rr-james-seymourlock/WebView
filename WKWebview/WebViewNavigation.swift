//
//  WebViewNavigation.swift
//  WKWebview
//
//  Created by James Seymour-Lock on 8/19/23.
//

import WebKit

extension WebView.Coordinator {

    /**
     Determines if a given URL matches a specified pattern for restriction or whitelisting.

     This method is used to analyze a URL and decide if it matches certain criteria
     specified either in the `whitelistSchemes`, `whitelistURLs`, `restrictedSchemes`,
     or `restrictedURLs` lists. The method considers the URL's scheme (e.g., http, https)
     and its host (e.g., www.example.com).

     - Parameters:
       - url: The URL to check against the specified patterns.
       - pattern: The pattern string to check the URL against.
                  This can be a simple string or have a prefix "*all." to match subdomains.
       - isWhitelist: A boolean flag to indicate whether the check is against a whitelist pattern
                      or a restricted pattern. Defaults to false (restricted pattern).

     - Returns: A boolean indicating whether the URL matches the specified pattern.
                If it returns true, the URL is either allowed (whitelist) or restricted.
    */
    func matchesRestrictedPattern(url: URL, pattern: String, isWhitelist: Bool = false) -> Bool {

        // If the URL should be checked against the whitelist
        if isWhitelist {
            // Check if the URL's scheme is in the whitelist schemes.
            if parent.whitelistSchemes.contains(url.scheme ?? "") {
                return true
            }
        }
        // If the URL should be checked against the restricted list
        else {
            // Check if the URL's scheme is in the restricted schemes.
            if parent.restrictedSchemes.contains(url.scheme ?? "") {
                return true
            }
        }

        // Note: The above check for restricted schemes seems redundant with the check below.
        // Consider removing one for cleaner code.

        // Check against restricted schemes
        if parent.restrictedSchemes.contains(url.scheme ?? "") {
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


    /**
     Decides navigation policy for the WebView based on various criteria.

     This method evaluates the URL that the WebView is attempting to navigate to. Depending on the
     URL and its properties, it might allow the navigation, restrict it, or present a user with a
     choice.

     The method checks the URL against whitelist and restricted lists, both in terms of specific URLs and schemes.

     - Parameters:
       - webView: The WebView that's trying to initiate the navigation.
       - navigationAction: Contains details about the navigation action.
       - decisionHandler: A closure that's called with the policy decision (allow, cancel).

     Note: This method can be enhanced by modularizing certain functionalities and
           avoiding hard-coded strings for more flexibility and maintainability.
    */
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

        // Ensure there's a valid URL to process.
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }

        // If the navigation target is the main frame (not an iframe or other embedded content)
        // and isn't a default "about:blank" page, log and store it.
        if navigationAction.targetFrame?.isMainFrame ?? false && url.absoluteString != "about:blank" {
            print("Navigating to: \(url)")

            // Store unique URLs that the WebView has navigated to.
            if !parent.loadedURLs.contains(url) {
                parent.loadedURLs.append(url)
            }
        }

        // Check if the URL or its scheme is whitelisted.
        if parent.whitelistURLs.contains(where: { matchesRestrictedPattern(url: url, pattern: $0, isWhitelist: true) })
        || parent.whitelistSchemes.contains(url.scheme ?? "") {
            decisionHandler(.allow)
            return
        }

        // Check if the URL is in the restricted list.
        if parent.restrictedURLs.contains(where: { matchesRestrictedPattern(url: url, pattern: $0) }) {

            // Alert the user about potential loss of benefits if they navigate away.
            let alert = UIAlertController(title: "Leaving Rakuten? You'll miss out on Cash Back.",
                                          message: "Do you really want to visit \(url.host ?? "this site")?",
                                          preferredStyle: .alert)

            // Option to stay on the current page.
            alert.addAction(UIAlertAction(title: "Keep shopping with Rakuten",
                                          style: .cancel,
                                          handler: { _ in
                                              decisionHandler(.cancel)
                                          }))

            // Option to proceed to the new URL.
            alert.addAction(UIAlertAction(title: "Leave Rakuten",
                                          style: .default,
                                          handler: { _ in
                                              decisionHandler(.allow)
                                          }))

            // Present the alert to the user.
            if let viewController = webView.window?.rootViewController {
                viewController.present(alert, animated: true)
            }
        } else {
            // If the URL is neither whitelisted nor restricted, allow the navigation.
            decisionHandler(.allow)
        }
    }
}

