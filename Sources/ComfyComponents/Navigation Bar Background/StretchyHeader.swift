//
//  StretchyHeader.swift
//  ComfyComponents
//
//  Created by Ethan Chaffin on 4/5/26.
//

import Foundation
import SwiftUI

struct StretchyHeader<B: View, F: View>: ViewModifier {
    @State var scrollOffsetY = Double()
    @State var viewHeight: Double = 0.0
    @State var safeAreaTop: Double = 0.0
    @State private var visibleWidth: Double = 0.0

    var backgroundParallax: Double = 0.30
    var foregroundParallax: Double = 0.40

    let imageRatio: Double

    let background: (Double) -> B
    var foreground: ((Double) -> F)?

    private var headerProgress: Double {
        let visibleHeight = viewHeight + scrollOffsetY //+ safeAreaTop
        return max(0, min(1, visibleHeight / viewHeight))
    }

    func body(content: Content) -> some View {
        content
            .contentMargins(.top, max(viewHeight, 0) + 16, for:.scrollContent)
        // tsk tsk tsk... you can't interact with it if it's a background, but as an overlay it tries to steal gestures
            .overlay(alignment: .top) {
                backgroundForegroundView
                    .frame(height: max(viewHeight + scrollOffsetY, 0),
                           alignment: .top)
                    .clipped()
                    .ignoresSafeArea(edges: .top)
            }
            .onGeometryChange(for: Double.self) { geo in
                geo.size.width
            } action: { _, newWidth in
                visibleWidth = newWidth
                viewHeight = visibleWidth * imageRatio
            }
            .onScrollGeometryChange(for: Double.self) { geo in
                geo.contentOffset.y
            } action: { _, offsetY in
                scrollOffsetY = -offsetY
            }
            .onScrollGeometryChange(for: Double.self) { geo in
                geo.contentInsets.top
            } action: { _, top in
                safeAreaTop = top
                viewHeight = visibleWidth * imageRatio
            }
    }

    @ViewBuilder
    var backgroundForegroundView: some View {
        ZStack(alignment: .top) {
            background(headerProgress)
                .frame(width: visibleWidth,
                       height: max(
                        viewHeight + scrollOffsetY,
                        viewHeight + safeAreaTop
                       ))//, alignment: .bottom)
                .offset(
                    y: scrollOffsetY - safeAreaTop < 0
                    ? (scrollOffsetY - safeAreaTop) * backgroundParallax
                    : 0
                )
            if let foreground = foreground {
                AnyView(foreground(headerProgress))
                    .padding(.top, safeAreaTop)
                    .frame(width: visibleWidth,
                           height: max(
                            viewHeight + scrollOffsetY,
                            viewHeight + safeAreaTop
                           ),
                           alignment: .bottom)
                    .offset (
                        y: scrollOffsetY - safeAreaTop < 0
                        ? (scrollOffsetY - safeAreaTop) * foregroundParallax
                        : 0
                    )
            }
        }
    }
}

public extension View {
    func stretchyHeader<Background: View, Foreground: View>(
        ratio: Double = 0.75,
        @ViewBuilder background: @escaping (Double) -> Background,
        @ViewBuilder foreground: @escaping (Double) -> Foreground
    ) -> some View {
        self.modifier(StretchyHeader(imageRatio: ratio, background: background, foreground: foreground))
    }

    /// A stretchy header! It will take at most (top safe area + view height) / 2 of the scrollable area. Ratio decreases it further; the calculation goes as such: If the ratio is set to 0.50, then the header will be (top safe area) + 1/4 of the screen tall.
    func stretchyHeader<Background: View>(
        ratio: Double = 0.75,
        @ViewBuilder background: @escaping (Double) -> Background
    ) -> some View {
        self.modifier(StretchyHeader(imageRatio: ratio, background: background, foreground: { _ in EmptyView() }))
    }
}

#Preview {
    NavigationStack {
        List {
            ForEach(0..<50) { index in
                Text("Hi")
            }
        }
        .navigationTitle("Hello")
        .toolbarTitleDisplayMode(.inlineLarge)
        .stretchyHeader(ratio: 0.25) { _ in
            LinearGradient(colors: [.red, .blue], startPoint: .top, endPoint: .bottom)
        } foreground: { _ in
            AsyncImage(url: URL(string:"https://raw.githubusercontent.com/PokeAPI/sprites/refs/heads/master/sprites/items/dream-world/aguav-berry.png"))
                .padding()
        }
    }

}


