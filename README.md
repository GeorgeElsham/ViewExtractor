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

<img width="400" alt="Example #1 result" src="https://user-images.githubusercontent.com/40073010/202593448-02ad4069-0c9a-4bff-85cd-ddd9313b3c51.png">


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

<img width="400" alt="Example #2 result" src="https://user-images.githubusercontent.com/40073010/202593730-594d45f9-6abf-46a8-8dba-1f93ec89e55d.png">


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

<img width="400" alt="Example #3 result" src="https://user-images.githubusercontent.com/40073010/202593772-bf61b3bb-3d64-4d5f-8a57-1132ed2ba2d2.png">


  [1]: https://developer.apple.com/documentation/swift_packages/adding_package_dependencies_to_your_app#3234996
