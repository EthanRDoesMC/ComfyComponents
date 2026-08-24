# Using ComfyNavigation

ComfyNavigation is a ready-to-use SwiftUI navigation system that requires about as much setup as a standard navigation stack destinations modifier, but it comes with a lot of conveniences.

## Overview

There are some very nice navigation solutions out there. ComfyNavigation is certainly not the best, but it is - in my opinion - the easiest to use. It does lack in a few areas -- you can't present sheets or full screen overlays as part of the path, for example -- but ComfyNavigation excels in being just plain easy for tying together the things that SwiftUI makes needlessly painful.

The best example case is probably the Zoom navigation transition. Why on EARTH does it require a namespace?? I mean, I know why, but that's just... awful. There really should've been something devised separately for navigationDestination for that modifier. Anyway, ComfyNavigation has you covered. It provides a namespace you can use across your navigation stack as an environment value. 

Also, every ComfyNavigation navigation is unique. That means you can navigate to the same destination multiple times without confusing NavigationStack.

### The easy way

First of all, all of the ComfyNavigation views expect something that conforms to ``ComfyNavigation``. The only real requirement here is Hashable, although if you can afford to do so, conforming to Codable will bring in guaranteed state restoration for free. (If your underlying types are Codable, state restoration will still work; note the word *guaranteed*.)

I'd recommend using an enum here, like so:

```swift
enum NavDest: ComfyNavigation {
    case home
    case page(page: Page)
    case detail(detail: Detail)
    // If your values don't conform to Hashable right out of the gate, you could always implement it yourself. 
    // Same with Codable, which makes passing SwiftData models directly a bit easier than conforming the types themselves to Codable!
}
```

Then, you can use the built-in ``ComfyNavigationStack``:

```swift
// in some view builder...
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
    }
}
```

- Note: I'm aware the syntax for that closure is a little awkward. SwiftUI likes to know its types, and the best thing we can do for it is for us to explain exactly what kind of destinations it should expect. 

### Manipulating the path

There are times when using a button to manipulate the path is preferable to a NavigationLink, like in the instance of a cell in a List. The cell, of course, should lead to its detail, but what if we wanted to be able to navigate to other places with buttons on that cell? You'd need an independent Button, then. Well, now you have to pass down a NavigationPath, which makes previewing a pain, yada yada yada - let's skip to the chase. Here's what you do in ComfyNavigation to modify the path, assuming you're within a destinationsContainer context (if you're using ComfyNavigationStack, you are):

```swift
struct MyView: View {
    @Environment(\.comfyNavigation) var navigation /// if the type-checker is having a fit, you can add `: ComfyNavigation?` to the end of this

    var body: some View {
        Button("Add to path!") {
            navigation?.path.append(NavDest.page(page)) /// IMPORTANT: Use your navigation type or the type will be different and SwiftUI will (rightfully) claim you haven't defined a destination for your model!
        }
    }
}
```

How about that?

Zoom transitions are just as easy. Let's say we added a case to NavDest called `picture(picture: Picture)`, and assume Picture is Identifiable. Let's make it so the user can full-screen the image. 


There is a namespace parameter included in our navigation destinations closure, and we can use it for just this.

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
    // starting here!
    case picture(let picture):
        PictureView(picture: picture)
            .navigationTransition(.zoom(sourceID: picture.id, in: namespace))
    }
}
```

Then, when we want to zoom to it...

```swift
struct MyView: View {
    @Environment(\.comfyNamespace) var namespace // bring in the namespace from the stack
    let picture: Picture
    
    var body: some View {
        // you will likely forget to use your enum a few times, because I do too
        // This does NOT have to be a navigation link, pushing to the path as described earlier works just fine too
        NavigationLink(value: NavDest.picture(picture)) { 
            Image(picture.image)
                .matchedTransitionSource(id: picture.id, in: namespace!) /// If you aren't sure about this unwrap, you could provide your own @Namespace and do `namespace ?? localNamespace`. All of *my* navigation is wrapped in ComfyNavigationStack and so I am comfortable unwrapping here.
        }
    }
}
```

That's it!

### Reusing destinations

If you have a tab view, you might find it redundant to have to do destinations multiple times.

The easy way around this is to just wrap ComfyNavigationStack:

```swift
struct MyNavigationStack<MyContent: View>: View {
    let name: String
    let myContent: MyContent
    
    var body: some View {
        ComfyNavigationStack(name) {
            myContent
        } destinations: { 
            // your destinations closure
        }
    }
}
```

### The hard way

You *can* implement your own sort of ComfyNavigationStack, but I honestly don't feel like typing any more and if you're going to do that, you should be able to find out what you need to know from the ComfyDestinationsContainer file. The important part is passing down a ComfyNavigation and a Namespace to the items on the path. NavigationStack isn't the best at doing that so we have destinationsContainer to enforce it.
