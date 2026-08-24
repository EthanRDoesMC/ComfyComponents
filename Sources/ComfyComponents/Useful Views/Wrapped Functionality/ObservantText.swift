//
//  ObservantText.swift
//  ComfyComponents
//
//  Created by Ethan Chaffin on 7/8/26.
//

import SwiftUI
import Combine

/// Observe a value from a publisher. Useful for KVO.
/// ```swift
/// ObservantText(object.publisher(for: \.kvoValue))
/// ```
public struct ObservantText<P: Publisher>: View where P.Output: CustomStringConvertible, P.Failure == Never {
    @State private var value: CustomStringConvertible
    private let publisher: P
    private let format: ((CustomStringConvertible) -> String)?

    public init(_ publisher: P, placeholder: CustomStringConvertible = "", format: ((CustomStringConvertible) -> String)? = nil) {
        self.publisher = publisher
        _value = .init(initialValue: placeholder)
        self.format = format
    }

    public var body: some View {
        Text(String(describing: value))
            .onReceive(publisher) { output in
                value = format?(output) ?? output
            }
    }
}
