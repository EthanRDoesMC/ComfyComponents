//
//  SafariView.swift
//  ComfyComponents
//
//  Created by Ethan Chaffin on 6/22/26.
//

import SwiftUI
import SafariServices

/// A simple SFSafariViewController. Why on earth isn't this included??
public struct SafariView: UIViewControllerRepresentable {
    public let url: URL
    public var configuration: SFSafariViewController.Configuration = .init()

    public init(url: URL, configuration: SFSafariViewController.Configuration = .init()) {
        self.url = url
        self.configuration = configuration
    }

    public func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
        return SFSafariViewController(url: url, configuration: configuration)
    }

    public func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {

    }

}
