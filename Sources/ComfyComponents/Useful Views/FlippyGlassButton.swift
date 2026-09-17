//
//  FlippyGlassButton.swift
//  ComfyComponents
//
//  Created by Ethan Chaffin on 6/20/26.
//

import SwiftUI

struct FlippyGlassButton<T: Shape>: ViewModifier {
    var isOn: Bool
    let shape: T
    let tint: Color?

    func body(content: Content) -> some View {
        GlassEffectContainer {
            if isOn {
                content
                    .buttonStyle(.plain)
                    .padding(8)
                    .foregroundStyle(.regularMaterial)
                    .colorScheme(.light)
                    .glassEffect(.regular.tint(tint ?? .accentColor).interactive(), in: shape)

            } else {
                content
                    .buttonStyle(.plain)
                    .padding(8)
                    .glassEffect(.regular.interactive(), in: shape)
            }
        }
        .animation(.default, value: isOn)
    }
}

public extension Button {
    /// Pair this with a button whose style is .plain and give its label some padding. This needs to be on a button because the hitbox of the button needs to be the same as this modifier; it should be the closest modifier to the button (or only button modifiers may precede it).
    func flippyGlass(_ isOn: Bool, shape: some Shape = .capsule, tint: Color? = nil) -> some View {
        self.modifier(FlippyGlassButton(isOn: isOn, shape: shape, tint: tint))
    }
}

public extension Menu {
    /// Pair this with a button whose style is .plain and give its label some padding. This needs to be on a button because the hitbox of the button needs to be the same as this modifier; it should be the closest modifier to the button (or only button modifiers may precede it).
    func flippyGlass(_ isOn: Bool, shape: some Shape = .capsule, tint: Color? = nil) -> some View {
        self.modifier(FlippyGlassButton(isOn: isOn, shape: shape, tint: tint))
    }
}

// This looks AWFUL in SwiftUI Previews, try it on device before you make a value judgement!
#Preview("Modifier") {
    @Previewable @State var active: Bool = true
    VStack(spacing: 32) {
        Button("upvote", systemImage: "arrow.up") {
            active.toggle()
        }
        .flippyGlass(active, shape: .capsule, tint: .red)
        .bold()

        Button("upvote", systemImage: "arrow.up") {
            active.toggle()
        }
        .flippyGlass(active, shape: .circle, tint: .orange)
        .labelStyle(.iconOnly)
        .bold()
    }
}
