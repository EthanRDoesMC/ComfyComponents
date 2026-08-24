//
//  ComfyDestinationsContainer.swift
//  ComfyComponents
//
//  Created by Ethan Chaffin on 7/17/26.
//

import Foundation
import SwiftUI

/// This is the primary logic of ComfyNavigation: Providing an enum-based switch while also sending a ComfyNavigation object to modify and a namespace to run transitions on. This makes a lot of things easier to just get up and running. With ComfyUniqueNavigation you can also rest assured that every transition in the namespace will be fully unique.
/// If you're using a navigation stack you don't control, you could integrate ComfyNavigation with this container. You won't get path restoration for free, though.
public struct ComfyDestinationsContainer<Destination: ComfyDestination, Content: View, DestinationContent: View>: View {
    @Environment(\.comfyNavigation) var navigation
    @Environment(\.comfyNamespace) var namespace

    let destinationSwitch: (Destination, Namespace.ID) -> (DestinationContent)
    @ViewBuilder let content: Content

    public var body: some View {
        content
            .navigationDestination(for: ComfyUniqueNavigation<Destination>.self) { dest in
                destinationSwitch(dest.value, namespace!)
                    .environment(\.comfyNamespace, namespace)
                    .environment(\.comfyNavigation, navigation)
            }
            .environment(\.comfyNamespace, namespace)
            .environment(\.comfyNavigation, navigation)
    }
}

public extension View {
    @ViewBuilder func navigationDestinations<Destination: ComfyDestination, DestinationContent: View>(
        navigation: ComfyNavigation? = nil,
        namespace: Namespace.ID? = nil,
        @ViewBuilder destinations: @escaping (Destination, Namespace.ID) -> DestinationContent
    ) -> some View {
        ComfyDestinationsContainer(destinationSwitch: destinations, content: {self})
        .environment(\.comfyNavigation, navigation)
        .environment(\.comfyNamespace, namespace)
    }
}

/// This should get you up and running. It brings some state restoration in for free, if the ComfyDestinations you pass in are Codable. (You'll get a runtime error log if they aren't but don't sweat it. Either conform your destination type to Codable for assurance that it will always work or just know that it will work on the most-recent Codable path.)
/// - Note: Make sure you include an explicit type annotation in the closure for Destination. If your destination enum is called NavigationDest, you'd do it like so:
///  ```
///  ComfyNavigationStack("Books") {
///      BooksView()
///  } destinations: { (dest: NavigationDest, namespace) in
///      switch dest {
///      case .category(let cat):
///          Text(cat.displayName)
///      }
///  }
///  ```
///
///  DestinationContent is a stongly-typed constraint and you cannot extend ComfyNavigationStack to provide it with default values. Instead you should either wrap ComfyNavigationStack or create a static func somewhere and use that as the argument. Up to you; I'd recommend the former.
///
public struct ComfyNavigationStack<Content: View, Destination: ComfyDestination, DestinationContent: View>: View {
    @State private var navigation: ComfyNavigation
    @ViewBuilder public let content: Content
    @ViewBuilder public let destinationSwitch: (Destination, Namespace.ID) -> (DestinationContent)

    @Namespace private var namespace
    @State private var started = false

    @SceneStorage private var restorationData: Data?

    public let startingAt: Destination?

    public var body: some View {
        NavigationStack(path: $navigation.path) {
            content
                .navigationDestinations(navigation: navigation,
                                       namespace: namespace,
                                       destinations: destinationSwitch)
        }
        .onChange(of: navigation.path) { oldValue, newValue in
            if let path = try? JSONEncoder().encode(navigation.path.codable) {
                restorationData = path
            }
        }
        .onAppear {
            restore(startingAt: startingAt)
        }
    }

    private func restore(startingAt: Destination? = nil) {
        guard !started else { return }; started = true
        if let restorationData {
            do {
                let codable = try JSONDecoder().decode (
                    NavigationPath.CodableRepresentation.self, from: restorationData
                )
                navigation.path = NavigationPath(codable)
            } catch {
                print(#file, #line, error)
            }
        }
        if let startingAt, navigation.path.isEmpty {
            navigation.path.append(startingAt)
        }
    }

    /// - Parameters:
    ///   - name: A unique name for state restoration. (This name is *initialized* and does not need to be static.)
    ///   - startingAt: A Destination you can navigate to on the view's first appearance. (This would be pushed on top of the root view.)
    ///   - destinations: A closure you should use to specify navigation destinations, similar to .navigationDestination. See ``Using ComfyNavigation`` for more.
    public init(_ name: String, startingAt: Destination? = nil, @ViewBuilder content: @escaping () -> Content,
                @ViewBuilder destinations: @escaping (Destination, Namespace.ID) -> (DestinationContent)) {
        self.content = content()
        self.navigation = ComfyNavigation()
        self.startingAt = startingAt
        self._restorationData = SceneStorage(name)
        self.destinationSwitch = destinations
    }
}
