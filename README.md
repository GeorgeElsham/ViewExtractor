# ViewExtractor

Extract SwiftUI views from ViewBuilder content.


## Installation

Follow the instructions at [Adding Package Dependencies to Your App][1] to find out how to install the Swift package. Use the link of this GitHub repo as the URL (`https://github.com/GeorgeElsham/ViewExtractor`).


## Example

Here is an example which creates a `VStack` with `Divider()`s in between.

### View code

```swift
struct DividedVStack: View {
    private let views: [AnyView]
    
    init<Views>(@ViewBuilder content: ViewContent<Views>) {
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


  [1]: https://developer.apple.com/documentation/swift_packages/adding_package_dependencies_to_your_app#3234996
