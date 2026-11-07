//
//  Label+Convenience.swift
//  ComfyComponents
//
//  Created by Ethan Chaffin on 6/16/26.
//

import Foundation
import SwiftUI

public extension Label where Icon == EmptyView {

    /// Convenience initializer for `Label` with no icon and a custom label view.
    init(@ViewBuilder title: () -> Title) {
        self.init(title: title, icon: { EmptyView() })
    }

    /// Convenience initializer for `Label` with no icon and a `String` title.
    init(_ title: String) where Title == Text {
        self.init(title: { Text(title) }, icon: { EmptyView() })
    }
}

public extension Label where Title: View, Icon == Image {

    /// Convenience initializer for `Label` with a system image name and a Title view.
    init(systemImage: String, @ViewBuilder title: () -> Title) {
        self.init(title: title, icon: { Image(systemName: systemImage) })
    }

    /// Convenience initializer for `Label` with an image resource name and a Title view.
    init(image: String, @ViewBuilder title: () -> Title) {
        self.init(title: title, icon: { Image(image) })
    }
}
