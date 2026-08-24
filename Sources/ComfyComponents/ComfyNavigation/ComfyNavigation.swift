//
//  ComfyNavigation.swift
//  ComfyComponents
//
//  Created by Ethan Chaffin on 6/8/26.
//

import Foundation
import SwiftUI
import Combine
import Observation

/// ComfyDestination was designed with enums in mind. You should make an enum that conforms to it:
/// ```swift
/// enum Destination: ComfyDestination {
///     case home
///     case post(post: Post)
///     case settings
/// }
/// ```
/// and so forth.
/// ComfyDestination itself doesn't do much, but allows separation between *a hashable destination* and a *Comfy destination* for purposes of automatically wrapping it in UniqueDestination. I do not imagine myself the arbiter of a perfect navigation solution and have made this fairly modular if you need it to be so.
///
public protocol ComfyDestination: Hashable {

}

@Observable
public final class ComfyNavigation {
    var path = NavigationPath()

    init(path: NavigationPath = NavigationPath()) {
        self.path = path
    }
}

public extension EnvironmentValues {
    @Entry var comfyNamespace: Namespace.ID? = nil
    @Entry var comfyNavigation: ComfyNavigation? = nil
}

/// ComfyUniqueNavigation wraps a destination (doesn't have to be Comfy, but might as well) in a unique ID so that navigation actions are *guaranteed* unique. That way apps can be navigated freely and orthogonally.
public struct ComfyUniqueNavigation<T: Hashable>: Hashable {
    let value: T
    var id: UUID = UUID()

    init(_ entry: T) {
        self.value = entry
    }

    public static func == (lhs: Self, rhs: Self) -> Bool { lhs.id == rhs.id }
    public func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

/// These extensions go ahead and wrap all ComfyDestinations in UniqueNavigation objects.

public extension NavigationLink {
    init<E: ComfyDestination>(value entry: E, @ViewBuilder label: () -> Label)
    where Destination == Never {
        self.init(value: ComfyUniqueNavigation(entry), label: label)
    }
}

public extension NavigationLink where Label == Text {
    init<E: ComfyDestination>(_ title: some StringProtocol, value entry: E)
    where Destination == Never {
        self.init(value: ComfyUniqueNavigation(entry)) { Text(title) }
    }
}

public extension NavigationPath {
    mutating func append<E: ComfyDestination>(_ entry: E) {
        self.append(ComfyUniqueNavigation(entry))
    }
}
