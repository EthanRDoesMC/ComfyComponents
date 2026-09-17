//
//  HeroTitleModifier.swift
//  ComfyComponents
//
//  Created by Ethan Chaffin on 4/23/25.
//

import SwiftUI

@available(iOS 18, macOS 15, watchOS 11, *)
struct HeroTitleModifier: ViewModifier {
    @ViewBuilder var background: any View
    @State private var scrollOffsetY = Double()

    func body(content: Content) -> some View {
        content
            .onScrollGeometryChange(for: Double.self) { geo in
                geo.contentOffset.y
            } action: { oldOffset, offsetY in
                // This is here to animate it in when tapping the navbar to scroll up, I think. I wrote this a long time ago. I should revisit it.
                if abs(oldOffset - offsetY) >= 80, /*!interactive, */oldOffset != 0 {
                    withAnimation(.easeInOut(duration:0.20)) {
                        scrollOffsetY = -offsetY
                    }
                } else {
                    scrollOffsetY = -offsetY
                }
            }

            .background(alignment: .top) {
                Rectangle()
                    .fill(Color.clear)
                    .background (
                        AnyView(background)
                            .aspectRatio(contentMode: .fill)
                    )
                    .mask(
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: .black.opacity(0.5), location: 0),
                                .init(color: .black.opacity(0), location: 1)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .clipped()
                    .frame(maxHeight: max(0, scrollOffsetY))
                    .ignoresSafeArea()
            }
            .scrollEdgeEffectStyle(visible ? nil : .automatic, for: .top)
            .animation(.default, value: visible)
    }

    var visible: Bool {
        max(0, scrollOffsetY) > 0
    }
}

@available(iOS 18, macOS 15, watchOS 11, *)
#Preview("ScrollView") {
    @Previewable @State var text = ""
    NavigationStack {
        ScrollView {
            ForEach(0..<20) {_ in
                HStack {
                    NavigationLink {
                        ScrollView {
                            HStack {
                                Text("detail")
                            }
                            .frame(maxWidth:.infinity)
                        }
                        .heroHeader({
                            LinearGradient(gradient: Gradient(colors: [.blue,.red]), startPoint: .top, endPoint: .bottom)
                        })

                        .navigationTitle("Detail")
                    } label: {
                        Text("link to detail")
                    }
                }.frame(maxWidth:.infinity)
            }
        }
        .heroHeader({
            AsyncImage(url: URL(string:"https://upload.wikimedia.org/wikipedia/commons/f/fc/Kajikazawa_in_Kai_province.jpg")) { image in
                image.resizable()
            } placeholder: {

            }
        })
        .searchable(text:$text,placement: .navigationBarDrawer)

        .navigationTitle("Title")

    }
}

@available(iOS 18, macOS 15, watchOS 11, *)
#Preview("List") {
    @Previewable @State var text = ""
    NavigationStack {
        List {
            ForEach(0..<20) {_ in
                HStack {
                    NavigationLink {
                        ScrollView {
                            HStack {
                                Text("detail")
                            }
                            .frame(maxWidth:.infinity)
                        }
                        .heroHeader({
                            LinearGradient(gradient: Gradient(colors: [.blue,.red]), startPoint: .top, endPoint: .bottom)
                        })

                        .navigationTitle("Detail")
                    } label: {
                        Text("link to detail")
                    }
                }.frame(maxWidth:.infinity)
            }
        }
        .heroHeader({
            AsyncImage(url: URL(string:"https://upload.wikimedia.org/wikipedia/commons/f/fc/Kajikazawa_in_Kai_province.jpg")) { image in
                image.resizable()
            } placeholder: {

            }
        })
        .searchable(text:$text,placement: .navigationBarDrawer)

        .navigationTitle("Title")

    }
}
