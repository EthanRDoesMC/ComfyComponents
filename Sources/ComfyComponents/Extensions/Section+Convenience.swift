//
//  Section+Convenience.swift
//  ComfyComponents
//
//  Created by Ethan Chaffin on 7/6/26.
//

import Foundation
import SwiftUI

public extension Section where Parent == Text, Content : View, Footer : View {
    init<S>(_ title: S, @ViewBuilder content: () -> Content, @ViewBuilder footer: () -> Footer) where S: StringProtocol {
        self.init(content: content, header: {Text(title)}, footer: footer)
    }
}

public extension Section where Content : View, Parent == EmptyView, Footer == Text {
    init<S>(footer: S, @ViewBuilder content: () -> Content) where S: StringProtocol {
        self.init {
            content()
        } header: {
            EmptyView()
        } footer: {
            Text(footer)
        }
    }
}
