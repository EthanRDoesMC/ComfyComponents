//
//  ModestList.swift
//  ComfyComponents
//
//  Created by Ethan Chaffin on 9/16/26.
//

import SwiftUI

struct ModestListModifier: ViewModifier {
    @Binding var height: CGFloat
    func body(content: Content) -> some View {
        content
            .onScrollGeometryChange(for: CGFloat.self, of: \.contentSize.height) { oldValue, newValue in
                if newValue > oldValue {
                    height = newValue
                }
            }
    }
}

public struct ModestList<Content: View>: View {
    public let content: Content
    @State private var height: CGFloat = 10

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        List {
            content
        }
        .modifier(ModestListModifier(height: $height))
        .frame(maxHeight: height)
        .contentMargins(0, for: .automatic)
    }
}
