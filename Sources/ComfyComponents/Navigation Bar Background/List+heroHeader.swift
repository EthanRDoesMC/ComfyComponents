//
//  List+heroHeader.swift
//  ComfyComponents
//
//  Created by Ethan Chaffin on 4/25/25.
//

import SwiftUI

@available(iOS 18, macOS 15, watchOS 11, *)
public extension View {

    /// Adds a "hero"-style header to a ScrollView or List. The `content` can be any kind of view, including ShapeViews such as LinearGradient. The frame of `content` will automatically change to match how far the user "pulls" the scroll view past its normal upper bounds.
    /// - Parameters:
    ///   - content: a View. If using an Image or AsyncImage, it's recommended to make it `.resizable()`
    /// - Returns: A hero-style header to be used with a large navigation title.
    /// - Attention: This does not work when applied to horizontal scroll views.
    /// - Note: heroHeader is as unobtrusive as possible. The header will be exactly the width of the view it is applied to. If a ScrollView's width is narrow, the header will also be just as narrow. Additionally, heroHeader is not responsible for handling the color of the navigation bar title text.
    @MainActor func heroHeader(
        _ content: () -> some View
    ) -> some View {
        self
            .scrollContentBackground(.hidden)
            .modifier(HeroTitleModifier(background: content))
            .background {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
            }
    }

    @MainActor func heroHeader(_ url: URL?) -> some View {
        self
            .scrollContentBackground(.hidden)
            .modifier(HeroTitleModifier {
                AsyncImage(url: url) { state in
                    switch state {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .transition(.opacity.animation(.default))
                    default:
                        Color.clear
                    }
                }
            })
            .background {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
            }
    }
}
