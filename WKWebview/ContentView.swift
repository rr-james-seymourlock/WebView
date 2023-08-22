//
//  ContentView.swift
//  WKWebview
//
//  Created by James Seymour-Lock on 8/18/23.
//

import SwiftUI
import WebKit

struct ContentView: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: VStack(alignment: .leading) {
                }) {
                    NavigationLink(destination: BrowserView()) {
                        Text("Open Browser")
                    }
                }
            }
            .navigationBarTitle("WebView QA", displayMode: .automatic)
            .listStyle(InsetGroupedListStyle())
        }
    }
}

struct URLListView: View {
    @Binding var urls: [URL]
    @Binding var currentURL: URL
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        List(urls, id: \.self) { url in
            Button(action: {
                self.currentURL = url
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Text(url.absoluteString)
            }
        }
        .navigationBarTitle("Loaded URLs")
    }
}



struct BrowserView: View {
    @State private var currentURL = URL(string: "https://www.google.com")!
    @State private var loadedURLs: [URL] = []
    @State private var showURLList = false
    var body: some View {
        WebView(
            currentURL: $currentURL,
            initialURL: webviewSettings.initialURL,
            restrictedURLs: webviewSettings.restrictedURLs,
            restrictedSchemes: webviewSettings.restrictedSchemes,
            whitelistURLs: webviewSettings.whitelistURLs,
            whitelistSchemes: webviewSettings.whitelistSchemes,
            cssToInject: webviewSettings.removeBannerCSS,
            loadedURLs: $loadedURLs
        )
        .navigationBarTitle("Browser", displayMode: .inline)
        .navigationBarItems(trailing: Button("URL log") {
            self.showURLList = true
        })
        .ignoresSafeArea(.all)
        .sheet(isPresented: $showURLList) {
            URLListView(urls: $loadedURLs, currentURL: $currentURL)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
