//
//  ConfirmingButton.swift
//  ComfyComponents
//
//  Created by Ethan Chaffin on 5/29/26.
//

import SwiftUI

public struct ConfirmingButton<Label: View>: View {
    @ViewBuilder public var label: () -> Label
    public var message: String
    public var action: () -> Void

    @State private var showingConfirmation = false

    public var body: some View {
        Button(role: .destructive) {
            showingConfirmation = true
        } label: {
            label()
        }
        .confirmationDialog(message, isPresented: $showingConfirmation, titleVisibility: .visible) {
            Button("Confirm", role: .destructive) {
                action()
            }
        }
    }

    init(label: @escaping () -> Label, message: String, action: @escaping () -> Void, showingConfirmation: Bool = false) {
        self.label = label
        self.message = message
        self.action = action
        self.showingConfirmation = showingConfirmation
    }
}

public extension ConfirmingButton where Label == Text {
    init(_ label: String, message: String, action: @escaping () -> Void) {
        self.label = { Text(label) }
        self.message = message
        self.action = action
    }
}

#Preview {
    ConfirmingButton("test", message: "You sure?") {
        print("hello")
    }
}
