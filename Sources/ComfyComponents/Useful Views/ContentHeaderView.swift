//
//  ContentHeaderView.swift
//  ComfyComponents
//
//  Created by Ethan Chaffin on 2/19/26.
//  Could be better. A few extensions wouldn't hurt.

import SwiftUI

public struct ContentHeaderView: View {
    public var title: String
    public var systemImage: String?
    public var image: String?
    public var description: Text?
    public var body: some View {
        if let systemImage = systemImage {
            ContentUnavailableView(title, systemImage: systemImage, description: description)
                .padding(description != nil
                         ? [.bottom]
                         : [], padding)
                .alignmentGuide(.listRowSeparatorLeading) { dimensions in
                    dimensions[.leading]
                }
                .imageScale(.large)
        } else if let image = image {
            ContentUnavailableView(title, image: image, description: description)
                .padding(description != nil
                         ? [.bottom]
                         : [], padding)
                .alignmentGuide(.listRowSeparatorLeading) { dimensions in
                    dimensions[.leading]
                }
                .imageScale(.large)
        }
    }

    private let padding: CGFloat = {
        if #available(anyAppleOS 27, *) {
            -32
        } else { -16 }
    }()

    public init(_ title: String, image: String, description: Text? = nil) {
        self.title = title
        self.image = image
        self.description = description
    }

    public init(_ title: String, systemImage: String, description: Text? = nil) {
        self.title = title
        self.systemImage = systemImage
        self.description = description
    }
}

#Preview {
    List {
        Section {
            ContentHeaderView(
                "Test",
                systemImage: "person",
                description: Text("Hello")
            )
        }
        Section {
            ContentHeaderView(
                "Test",
                systemImage: "person"
            )
        }
    }
}
