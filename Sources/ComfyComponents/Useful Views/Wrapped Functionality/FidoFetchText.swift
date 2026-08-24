//
//  FidoFetchText.swift
//  ComfyComponents
//
//  Created by Ethan Chaffin on 7/15/26.
//

import SwiftUI
import Combine

/// "Observe" a value. Good for debugging.
public struct FidoFetchText: View {
    public let fetch: () async throws -> CustomStringConvertible
    @State private var value: CustomStringConvertible?

    public var body: some View {
        Text(value.map { String(describing: $0) } ?? "")
            .task {
                while !Task.isCancelled {
                    value = try? await fetch()
                    try? await Task.sleep(for: .seconds(1))
                }
            }
    }
}
