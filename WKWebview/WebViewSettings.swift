//
//  WebViewSettings.swift
//  WKWebview
//
//  Created by James Seymour-Lock on 8/19/23.
//
import Foundation

private let initialURL: URL = URL(string: "https://www.google.com")!
private let restrictedURLs: [String] = [
    "*all.onelink.me",
    "*all.app.link",
    "*all.smart.link",
    "*all.branch.link",
    "*all.deeplink.me",
    "*all.page.link",
    "onelink.me",
    "app.link",
    "smart.link",
    "branch.link",
    "deeplink.me",
    "page.link",
    "app.temu.com",
    "apps.apple.com",
    "itunes.apple.com",
]

private let restrictedSchemes: [String] = [
    "itms-appss"
]

private let whitelistURLs: [String] = []

private let whitelistSchemes: [String] = []

let webviewSettings = (
    initialURL: initialURL,
    restrictedURLs: restrictedURLs,
    restrictedSchemes: restrictedSchemes,
    whitelistURLs: whitelistURLs,
    whitelistSchemes: whitelistSchemes
)
