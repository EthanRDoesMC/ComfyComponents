//
//  SmartDisclosureView.swift
//  ComfyComponents
//
//  Created by Ethan Chaffin on 6/21/26.
//

import SwiftUI

/// Provide an action for how the scroll proxy should collapse. This is best used in tandem with List wrapped in a Scroll Proxy so that a collapsing section will scroll to the top of itself.
public struct SmartDisclosureView<Header: View, Content: View, Children: View>: View {

    public init(
        isExpanded: Binding<Bool>,
        sidebarColor: Color? = nil,
        proxyCollapseAction: (() -> Void)? = nil,
        @ViewBuilder header: () -> Header,
        @ViewBuilder content: () -> Content,
        @ViewBuilder children: () -> Children
    ) {
        self._isExpanded = isExpanded
        self.sidebarColor = sidebarColor
        self.proxyCollapseAction = proxyCollapseAction
        self.header = header()
        self.content = content()
        self.children = children()
    }

    @Binding var isExpanded: Bool
    @State private var shouldScrollOnCollapse: Bool = false
    var sidebarColor: Color?
    var proxyCollapseAction: (() -> ())?

    @ViewBuilder var header: Header
    @ViewBuilder var content: Content
    @ViewBuilder var children: Children

    public var body: some View {
        if isExpanded {
            HStack {
                if sidebarColor != nil {
                    Divider().frame(width:2).overlay(sidebarColor)
                }
                VStack(alignment: .leading) { header; content }
            }
            .onGeometryChange(for: Bool.self) { proxy in
                return proxy.frame(in: .scrollView).minY < 150
            } action: { isAboveNavbar in
                shouldScrollOnCollapse = isAboveNavbar
            }
            .background { Button("") {
                withAnimation(.default) {
                    if shouldScrollOnCollapse {
                        proxyCollapseAction?()
                    }
                    isExpanded.toggle()
                }}
            }
            children.padding(.leading, 8)
        } else {
            HStack {
                if sidebarColor != nil {
                    Divider().frame(width:2).overlay(sidebarColor)
                }
                header
            }
            .onGeometryChange(for: Bool.self) { proxy in
                return proxy.frame(in: .scrollView).minY < 150
            } action: { isAboveNavbar in
                shouldScrollOnCollapse = isAboveNavbar
            }
            .background { Button("") {
                // i would like the scroll to animate but it should really run after scroll geo calculations happen. I'm not sure that this does that either?
                withAnimation(.default) {
                    isExpanded.toggle()
                    if shouldScrollOnCollapse {
                        proxyCollapseAction?()
                    }
                }
            }}
        }
    }
}

#Preview {
    @Previewable @State var expanded = false
    @Previewable @State var other = false
    List {
        SmartDisclosureView(isExpanded: $expanded) {
            Text("Header!")
                .swipeActions {
                    Button("test") {
                        expanded = false
                    }
                }
        } content: {
            Text("Content!")
        } children: {
            Text("Children!")
            SmartDisclosureView(isExpanded: $other) {
                Text("Header!")
            } content: {
                Text("Content!")
            } children: {
                Text("Children!")
            }
        }
        Text("hello")
        SmartDisclosureView(isExpanded: $other) {
            Text("Header!")
        } content: {
            Text("Content!")
        } children: {
            Text("Children!")
        }
        SmartDisclosureView(isExpanded: $other) {
            Text("Header!")
        } content: {
            Text("Content!")
        } children: {
            Text("Children!")
        }
        SmartDisclosureView(isExpanded: $other) {
            Text("Header!")
        } content: {
            Text("Content!")
        } children: {
            Text("Children!")
        }
        SmartDisclosureView(isExpanded: $other) {
            Text("Header!")
        } content: {
            Text("Content!")
        } children: {
            Text("Children!")
        }
        SmartDisclosureView(isExpanded: $other) {
            Text("Header!")
        } content: {
            Text("Content!")
        } children: {
            Text("Children!")
        }
        SmartDisclosureView(isExpanded: $other) {
            Text("Header!")
        } content: {
            Text("Content!")
        } children: {
            Text("Children!")
        }

    }
}
