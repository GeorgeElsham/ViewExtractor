# ViewExtractor

Extract SwiftUI views from ViewBuilder content.


## Installation

Follow the instructions at [Adding Package Dependencies to Your App][1] to find out how to install the Swift package. Use the link of this GitHub repo as the URL (`https://github.com/GeorgeElsham/ViewExtractor`).


## Example #1

Here is an example which creates a `VStack` with `Divider()`s in between.

### View code

```swift
struct DividedVStack: View {
    private let views: [AnyView]
    
    // For 2 or more views
    init<Views>(@ViewBuilder content: TupleContent<Views>) {
        views = ViewExtractor.getViews(from: content)
    }
    
    // For 0 or 1 view
    init<Content: View>(@ViewBuilder content: NormalContent<Content>) {
        views = ViewExtractor.getViews(from: content)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(views.indices) { index in
                if index != 0 {
                    Divider()
                }
                
                views[index]
            }
        }
    }
}
```

### Usage

```swift
DividedVStack {
    Text("View 1")
    Text("View 2")
    Text("View 3")
    Image(systemName: "circle")
}
```

### Result

<img src="https://user-images.githubusercontent.com/40073010/115965850-f43c5d80-a522-11eb-8113-1f73d07fade0.png" width="25%">


## Example #2

Here is an example which creates a `VStack` of views, for every multiple of 2. The views are loaded lazily, so they aren't all computed at once which would waste resources if half of them aren't used.

### View code

```swift
struct IntervalVStack: View {
    private let extractor: ViewExtractor

    init<Content: View & DynamicViewContentProvider>(content: ForEachContent<Content>) {
        extractor = ViewExtractor(content: content)
    }

    var body: some View {
        VStack(spacing: 0) {
            ForEach(extractor.forEachRange!) { index in
                if index.isMultiple(of: 2) {
                    extractor.uncheckedView(at: index)
                }
            }
        }
    }
}
```

### Usage

```swift
IntervalVStack {
    ForEach(0 ..< 10) { index in
        Text("Index: \(index)")
    }
}
```

### Result

<img src="https://user-images.githubusercontent.com/40073010/127054749-e5d27295-f179-41bd-9517-3b2d0eb4b970.png" width="25%">


  [1]: https://developer.apple.com/documentation/swift_packages/adding_package_dependencies_to_your_app#3234996
