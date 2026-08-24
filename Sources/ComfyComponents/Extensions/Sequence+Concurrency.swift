//
//  Sequence+Concurrency.swift
//  ComfyComponents
//
//  Created by Ethan Chaffin on 3/26/26.
//  Based on https://www.swiftbysundell.com/articles/async-and-concurrent-forEach-and-map/
//  asyncCompactMap and concurrentCompactMap are my additions
//

import Foundation

public extension Sequence {
    func asyncMap<T>(
        _ transform: (Element) async throws -> T
    ) async rethrows -> [T] {
        var values = [T]()

        for element in self {
            try await values.append(transform(element))
        }

        return values
    }

    func asyncCompactMap<T>(
        _ transform: (Element) async throws -> T?
    ) async rethrows -> [T] {
        var values = [T]()

        for element in self {
            if let value = try await transform(element) {
                values.append(value)
            }
        }

        return values
    }

    func asyncForEach(
        _ operation: (Element) async throws -> Void
    ) async rethrows {
        for element in self {
            try await operation(element)
        }
    }

    func concurrentForEach(
        _ operation: @escaping @Sendable (sending Element) async throws -> Void
    ) async throws where Element: Sendable {
        let tasks = map { element in
            Task {
                try await operation(element)
            }
        }

        try await tasks.asyncForEach { task in
            try await task.value
        }
    }

    func concurrentMap<T: Sendable>(
        _ transform: @escaping @Sendable (sending Element) async throws -> T
    ) async throws -> [T] where Element: Sendable {
        let tasks = map { element in
            Task {
                try await transform(element)
            }
        }

        return try await tasks.asyncMap { task in
            try await task.value
        }
    }

    func concurrentCompactMap<T: Sendable>(
        _ transform: @escaping @Sendable (sending Element) async throws -> T?
    ) async throws -> [T] where Element: Sendable {
        let results = try await concurrentMap(transform)
        return results.compactMap { $0 }
    }
}
