//
//  Zoomable.swift
//  ComfyComponents
//
//  Created by Ethan Chaffin on 6/8/25.
//

import SwiftUI

/// Not the part you're supposed to use, y'know!
struct ZoomableWrapper<Content: View>: UIViewRepresentable {
    var content: () -> Content
    @Binding var idle: Bool
    var showsIndicators: Bool = false
    var bouncesZoom: Bool = true
    var singleTapMakesActive: Bool = true
    var minimumZoomScale: CGFloat = 1.0
    var maximumZoomScale: CGFloat = 5.0
    var decelerationRate: UIScrollView.DecelerationRate = .fast

    init(idle: Binding<Bool> = .constant(true),
         showsIndicators: Bool = false,
         bouncesZoom: Bool = true,
         singleTapMakesActive: Bool = true,
         minimumZoomScale: CGFloat = 1.0,
         maximumZoomScale: CGFloat = 5.0,
         decelerationRate: UIScrollView.DecelerationRate,
         @ViewBuilder _ content: @escaping () -> Content)
    {
        self.content = content
        self._idle = idle
        self.showsIndicators = showsIndicators
        self.bouncesZoom = bouncesZoom
        self.minimumZoomScale = minimumZoomScale
        self.maximumZoomScale = maximumZoomScale
        self.decelerationRate = decelerationRate
    }

    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator

        scrollView.maximumZoomScale = maximumZoomScale
        scrollView.minimumZoomScale = minimumZoomScale
        scrollView.bouncesZoom = bouncesZoom
        scrollView.showsVerticalScrollIndicator = showsIndicators
        scrollView.showsHorizontalScrollIndicator = showsIndicators
        scrollView.decelerationRate = decelerationRate
        scrollView.backgroundColor = .clear

        let hostedView = context.coordinator.hostingController.view!
        hostedView.translatesAutoresizingMaskIntoConstraints = true
        hostedView.autoresizingMask = [.flexibleWidth,
                                       .flexibleHeight]
        hostedView.frame = scrollView.bounds

        scrollView.addSubview(hostedView)

        // double-tap to zoom
        let doubleTapGesture = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(context.coordinator.handleDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTapGesture)

        // single-tap to "lock" ui a la photos app, use with the idle binding to control your background
        if singleTapMakesActive {
            let singleTapGesture = UITapGestureRecognizer(
                target: context.coordinator,
                action: #selector(context.coordinator.handleSingleTap(_:)))
            singleTapGesture.numberOfTapsRequired = 1
            scrollView.addGestureRecognizer(singleTapGesture)
            singleTapGesture.require(toFail: doubleTapGesture)
        }

        return scrollView
    }

    func updateUIView(_ uiView: UIScrollView, context: Context) {
        context.coordinator.hostingController.rootView = content()
        context.coordinator.parent = self
        if !context.coordinator.isStateLocked {
            context.coordinator.updateDefaultState(uiView)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIScrollViewDelegate {
        var parent: ZoomableWrapper
        var hostingController: UIHostingController<Content>
        internal var isStateLocked = false

        init(_ parent: ZoomableWrapper) {
            self.parent = parent
            self.hostingController = UIHostingController(rootView: parent.content())
            self.hostingController.view.backgroundColor = .clear
        }

        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            hostingController.view
        }

        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            updateDefaultState(scrollView)
        }

        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            updateDefaultState(scrollView)
        }

        internal func updateDefaultState(_ scrollView: UIScrollView) {
            // single tap lock
            guard !isStateLocked else { return }

            let isAtMinimumZoom = abs(scrollView.zoomScale - scrollView.minimumZoomScale) < 0.01
            let isAtOrigin = abs(scrollView.contentOffset.x) < 1.0 && abs(scrollView.contentOffset.y) < 1.0
            let newDefaultState = isAtMinimumZoom && isAtOrigin

            if parent.idle != newDefaultState {
                DispatchQueue.main.async {
                    withAnimation {
                        self.parent.idle = newDefaultState
                    }
                }
            }
        }

        // toggle for single-tap "ui locking" for idle mode
        @objc func handleSingleTap(_ gesture: UITapGestureRecognizer) {
            if isStateLocked {
                isStateLocked = false
                guard let scrollView = gesture.view as? UIScrollView else { return }
                updateDefaultState(scrollView)
            } else {
                isStateLocked = true
                DispatchQueue.main.async {
                    withAnimation {
                        self.parent.idle = false
                    }
                }
            }
        }

        @objc func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
            guard let scrollView = gesture.view as? UIScrollView else { return }

            if scrollView.zoomScale != scrollView.minimumZoomScale {
                scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
            } else {
                let location = gesture.location(in: scrollView)
                let zoomRect = zoomRectForScale(
                    scrollView: scrollView,
                    scale: scrollView.maximumZoomScale/2.0,
                    center: location)
                scrollView.zoom(to: zoomRect, animated: true)
            }
        }

        private func zoomRectForScale(scrollView: UIScrollView,
                                      scale: CGFloat,
                                      center: CGPoint) -> CGRect {
            let width = scrollView.bounds.size.width / scale
            let height = scrollView.bounds.size.height / scale
            let originX = center.x - (width / 2.0)
            let originY = center.y - (height / 2.0)
            return CGRect(x: originX, y: originY,
                          width: width, height: height)
        }
    }
}

public extension View {
    /// Makes a view zoomable by wrapping it in a scroll view
    /// - Parameters:
    ///   - idle: A Binding that, if true, means the scroll view is at its "resting" default position and state, the one it starts with. In other words, true if UI should be shown.
    ///         Optional, managed by state, starts as true.
    ///   - showsIndicators: Whether or not to show scroll indicators. Hey, your call!
    ///         Optional, defaults to true.
    ///   - bouncesZoom: Whether or not to have the zoom rubber-banding effect.
    ///         Optional, defaults to true.
    ///   - singleTapMakesActive: Whether a single tap should "lock" the UI into being active (not idle).
    ///         This works best if you're trying to recreate the Photos app; UI shouldn't be shown automatically if the user tapped, zoomed in, then zoomed back out.
    ///         Optional, defaults to true.
    ///   - minimumZoomScale: The smallest scale at which the view can remain after being let go.
    ///         Defaults to 1.0.
    ///   - maximumZoomScale: The largest scale at which the view can remain after being let go.
    ///         Defaults to 5.0.
    ///   - decelerationRate: How the scroll "slides". Defaults to .fast, which I recommend, but in case you need to change it, it's there.-
    func zoomable (
        idle: Binding<Bool> = .constant(true),
        showsIndicators: Bool = false,
        bouncesZoom: Bool = true,
        singleTapMakesActive: Bool = true,
        minimumZoomScale: CGFloat = 1.0,
        maximumZoomScale: CGFloat = 5.0,
        decelerationRate: UIScrollView.DecelerationRate = .fast
    ) -> some View {
        ZoomableWrapper (
            idle: idle,
            showsIndicators: showsIndicators,
            bouncesZoom: bouncesZoom,
            singleTapMakesActive: singleTapMakesActive,
            minimumZoomScale: minimumZoomScale,
            maximumZoomScale: maximumZoomScale,
            decelerationRate: decelerationRate
        ) { self }
    }
}

#Preview("Simple") {
    AsyncImage(url: URL(string:"https://upload.wikimedia.org/wikipedia/commons/f/fc/Kajikazawa_in_Kai_province.jpg")) { image in
        image
            .resizable()
            .aspectRatio(contentMode: .fit)
            .zoomable()
    } placeholder: {}
}

#Preview("Photos App Style") {
    @Previewable @State var showUI = true
    AsyncImage(url: URL(string:"https://upload.wikimedia.org/wikipedia/commons/f/fc/Kajikazawa_in_Kai_province.jpg")) { image in
        image
            .resizable()
            .aspectRatio(contentMode: .fit)
            .zoomable(idle: $showUI)
    } placeholder: {}
        .background {
            Color(showUI ? .systemBackground : .black)
        }
        .ignoresSafeArea()
}
