//
//  LabeledContent+Convenience.swift
//  ComfyComponents
//
//  Created by Ethan Chaffin on 7/6/26.
//

import Foundation
import SwiftUI

public extension LabeledContent where Label == SwiftUI.Label<Text, Image>, Content: View {
    init<S>(_ title: S, systemImage: String, @ViewBuilder content: () -> Content) where S: StringProtocol {
        self.init {
            content()
        } label: {
            SwiftUI.Label(title, systemImage: systemImage)
        }
    }
}

public extension LabeledContent where Label == SwiftUI.Label<Text, Image>, Content == Text {
    init<S>(_ title: S, systemImage: String, value: String) where S: StringProtocol {
        self.init {
            Text(value)
        } label: {
            SwiftUI.Label(title, systemImage: systemImage)
        }
    }
}
