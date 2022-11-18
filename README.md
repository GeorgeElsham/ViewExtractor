# ViewExtractor

Extract SwiftUI views from ViewBuilder content.


## Installation

Follow the instructions at [Adding Package Dependencies to Your App][1] to find out how to install the Swift package. Use the link of this GitHub repo as the URL (`https://github.com/GeorgeElsham/ViewExtractor`).


## Example #1

Create a vertical stack of views, separated by dividers.

### View code

```swift
struct DividedVStack<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        Extract(content) { views in
            VStack {
                let first = views.first?.id

                ForEach(views) { view in
                    if view.id != first {
                        Divider()
                    }

                    view
                }
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
}
```

### Result

<img src="" width="25%">


## Example #2

Create a vertical stack of views, only keeping views at indexes with a multiple of 2.

### View code

```swift
struct IntervalVStack<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        Extract(content) { views in
            VStack {
                ForEach(Array(zip(views.indices, views)), id: \.1.id) { index, view in
                    if index.isMultiple(of: 2) {
                        view
                    }
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

<img src="" width="25%">


## Example #3

Create a stack of views, returning multiple views as a result, allowing it to be wrapped by another view. When modifiers are applied, they apply to each view returned. Note the use of `ExtractMulti` rather than just `Extract`.

### View code

```swift
struct Divided<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        ExtractMulti(content) { views in
            let first = views.first?.id

            ForEach(views) { view in
                if view.id != first {
                    Divider()
                }

                view
            }
        }
    }
}
```

### Usage

```swift
HStack {
    Divided {
        Text("View 1")
        Text("View 2")
        Text("View 3")
    }
    .border(Color.red)
}
```

### Result

<img src="" width="25%">


  [1]: https://developer.apple.com/documentation/swift_packages/adding_package_dependencies_to_your_app#3234996
