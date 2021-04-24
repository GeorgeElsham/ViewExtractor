# ViewExtractor

Extract SwiftUI views from ViewBuilder content.


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
        VStack(alignment: .center, spacing: 0) {
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
