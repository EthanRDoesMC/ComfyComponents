# Comfy Components
## Comfy, easy to use components and extensions for Swift and SwiftUI.

Minimum `*OS 26.0`. 

## Overview
ComfyComponents is a set of utilities and components I have found to be helpful, ranging from a scale from "that took 5 seconds to make, I'm glad I did it" to "I cannot live without this". 

The flagship features are ComfyNavigation, HeroHeader, StretchyHeader, and the Sequence+Concurrency extensions. 

## Comfy Navigation

Wanna see the easiest navigation you've ever worked with?

```swift
enum NavDest: ComfyDestination, Codable {
    case home
    case page(page: Page)
    case detail(detail: Detail)
}
```

```swift
ComfyNavigationStack("Home") {
    HomeView()
} destinations: { (destination: NavDest, namespace) in 
    switch destination {
    case home:
        HomeView()
    case page(let page):
        PageView(page: page)
    case detail(let detail):
        DetailView(detail: detail)
            .navigationTransition(.zoom(sourceID: detail.id, in: namespace))
    }
}
```

```swift
struct MyView: View {
    // these become available to you...
    @Environment(\.comfyNavigation) var navigation // : ComfyNavigation?
    @Environment(\.comfyNamespace) var namespace // : Namespace.ID?
}
```

With that, you get state restoration, a namespace in your environment to use in transitions, a navigation path in your environment you can modify, and all of your values passed into that navigation path (or sent via NavigationLink) are given unique identifiers that won't confuse SwiftUI, so multiple of the same value can be on the path! Check out the docs for more info.

## Hero Header

Add a hero header to a List or ScrollView. These headers are kind of like a stretchy header, but keeping the sizing and styling of navigation bars (and thus your scroll view metrics) completely intact. They only exist on the background and have a fading gradient mask. A navigation title with white text on a fully white Hero Header is fully visible and vice versa. 

Since they are a part of the background, they cannot be interacted with. The fading background would not indicate interaction, though, so it's for the best.

Hero Header is one of the first modifiers I ever wrote, so if it's a bit clunky right now, sorry... I'll tidy it up.

```swift
struct MyView: View {
    var body: some View {
        NavigationStack { // important: the navigation bar does not appear without a navigation context of some kind
            List {
                Text("Hello!")
            }
            .heroHeader {
                Image("Hokusai_LightningsBelow")
                    .resizable() // image won't stretch without it!
                    .aspectRatio(contentMode: fill) // you COULD have it fit too, but I think it looks better to fill
                    // .transition(.opacity.animation(.default)) also works well within an async image
            }
        }
    }
}
```

## Flippy Glass

A simple toggle-button that animates its glass tinting in a bouncy way. These usually work well with bold symbols and text!

```swift
struct MyButton: View {
    @State var isOn = false
    
    var body: some View {
        Button("Press me!", systemImage: "play.fill") {
            isOn.toggle()
        }
        .flippyGlass(isOn)
    }
}
```

To make a round button:

```swift
struct MyButton: View {
    @State var isOn = false
    
    var body: some View {
        Button("Press me!", systemImage: "play.fill") {
            isOn.toggle()
        }
        .flippyGlass(isOn, shape: .circle, tint: .red)
        .labelStyle(.iconOnly)
        .bold()
    }
}
```

## Zoomable

Wraps your view in a UIScrollView so as to *properly* implement pinch-to-zoom and panning. Has all the defaults you'd want for it, but the init has plenty of customization to work with.

Simplest implementation:
```swift
Image("MyImage").zoomable()
```

But if you want to take it another step up, you can implement the `idle` binding property. "Idle" essentially means "show the UI" (looking back, I should've called it just that) and will be true whenever the user has not:
- single-pressed the view (to indicate hiding the UI and the background)
- zoomed in the image without having returned

Single-pressing the view will "lock" it out of idle mode, like in the Photos app. The only way to re-enter idle mode from that state is to tap again. Otherwise, idle mode will be false when panning and zooming begin -- but when the view returns to its default position and zoom, idle mode will be true again.

In the default implementation of zoomable, idle mode is always active. Idle mode does not actually affect anything controlled by the zoomable modifier, so it behaves the way you hope it would. 

Here's how you do a Photos app:

```swift
struct ImageView: View {
    let image: Image
    @State private var showUI = true
    
    var body: some View {
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
}
```

## SwiftUI Extensions

Semantics this, semantics that, when is Apple gonna ship enough combinations of initializers to be useful? I guess I'll do their job for them.

**Label**

```swift
Label {
    Text("Just the text")
    Text("No icon required")
}
```

```swift
Label("Just a title, no image required")
```

```swift
Label(systemImage: "megaphone") {
    Text("Now you can have your styled text")
    Text("without having to build an entire image")
}
```

**Section**

```swift
Section("Section title!") {
    // content
} footer: {
    Text("Footer text!")
}
```

```swift
Section(footer: "Footer text!") {
    // content
}
```

**LabeledContent**

```swift
LabeledContent("Label", systemImage: "music.note") {
    // content
}
```

```swift
LabeledContent("Label", systemImage: "music.note", value: 37)
```

