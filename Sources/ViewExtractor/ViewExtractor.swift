import SwiftUI

// MARK: - ViewExtractor

/// Extract SwiftUI views from ViewBuilder content.
public enum ViewExtractor {
    /// Represents a `View`. Can be used to get `AnyView` from `Any`.
    public struct GenericView {
        let body: Any

        /// Get `AnyView` from a generic view.
        var anyView: AnyView? {
            AnyView(_fromValue: body)
        }
    }

    /// Gets views from a `TupleView`.
    /// - Parameter content: Content to extract the views from.
    /// - Returns: Extracted views.
    public static func getViews<Views>(@ViewBuilder from content: TupleContent<Views>) -> [AnyView] {
        content().views
    }

    /// Get views from a normal view closure.
    /// - Parameter content: Content to extract the views from.
    /// - Returns: Extracted views.
    public static func getViews<Content: View>(@ViewBuilder from content: NormalContent<Content>) -> [AnyView] {
        ViewExtractor.views(from: content())
    }

    /// Gets views from `Any`. Also splits up `DynamicViewContent` into separate views.
    /// - Parameter view: View of `Any` type.
    /// - Returns: Views contained by this `view`.
    public static func views(from view: Any) -> [AnyView] {
        checkingViewContent(view) {
            // Just a normal view. Convert it from type `Any` to `AnyView`.
            withUnsafeBytes(of: view) { ptr -> [AnyView] in
                // Cast from type `Any` to `GenericView`,
                // which mimics the structure of a `View`.
                let binded = ptr.bindMemory(to: GenericView.self)

                // Get `AnyView` from the 'fake' view body.
                return binded.first?.anyView.map { [$0] } ?? []
            }
        }
    }

    /// Return the view content. This removes views like `EmptyView`,
    /// and gets content from within `ForEach`.
    ///
    /// - Parameters:
    ///   - view: View to test.
    ///   - actual: If this is a normal view, this content is used.
    /// - Returns: Array of content views.
    fileprivate static func checkingViewContent(_ view: Any, actual: () -> [AnyView]) -> [AnyView] {
        // Check this is not an empty view with no content.
        if view is EmptyView {
            return []
        }

        // If this view is a `ForEach`, extract all contained views.
        if let forEach = view as? DynamicViewContentProvider {
            return forEach.extractContent()
        }

        // Actual view.
        return actual()
    }
}

// MARK: - Content types

public typealias TupleContent<Views> = () -> TupleView<Views>
public typealias NormalContent<Content: View> = () -> Content

// MARK: - TupleView views

public extension TupleView {
    /// Convert tuple of views to array of `AnyView`s.
    var views: [AnyView] {
        let children = Mirror(reflecting: value).children
        return children.flatMap { ViewExtractor.views(from: $0.value) }
    }
}

// MARK: - Dynamic view content

public protocol DynamicViewContentProvider {
    func extractContent() -> [AnyView]
}

extension ForEach: DynamicViewContentProvider where Content: View {
    public func extractContent() -> [AnyView] {
        // Dynamically mirrors the current instance.
        let mirror = Mirror(reflecting: self)

        // Retrieving hidden properties containing the data and content.
        if let data = mirror.descendant("data") as? Data,
           let content = mirror.descendant("content") as? (Data.Element) -> Content
        {
            return data.flatMap { element -> [AnyView] in
                // Create content given the data for this `ForEach` element.
                let newContent = content(element)

                // Gets content for element.
                return ViewExtractor.checkingViewContent(newContent) {
                    [AnyView(newContent)]
                }
            }
        } else {
            // Return no content if failure.
            return []
        }
    }
}
