import SwiftUI


// MARK: ViewExtractor
/// Extract SwiftUI views from ViewBuilder content.
public enum ViewExtractor {
    /// Represents a `View`. Can be used to get `AnyView` from `Any`.
    public struct GenericView {
        let body: Any
        
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
    
    /// Get view creators from a `TupleView`.
    /// - Parameter content: Content to extract the views from
    /// - Returns: Extracted views
    public static func getViewCreators<Views>(@ViewBuilder from content: TupleContent<Views>) -> [() -> AnyView] {
        content().viewCreators
    }
    
    /// Get view creators from a normal view closure.
    /// - Parameter content: Content to extract the views from
    /// - Returns: Extracted views
    public static func getViewCreators<Content: View>(@ViewBuilder from content: NormalContent<Content>) -> [() -> AnyView] {
        ViewExtractor.viewCreators(from: content())
    }
        
    /// Gets views from `Any`. Also splits up `DynamicViewContent` into separate views.
    /// - Parameter view: View of `Any` type.
    /// - Returns: Views contained by this `view`.
    public static func views(from view: Any) -> [AnyView] {
        if view is EmptyView {
            return []
        }
        if let forEach = view as? DynamicViewContentProvider {
            return forEach.extractContent()
        }
        
        return withUnsafeBytes(of: view) { ptr -> [AnyView] in
            let binded = ptr.bindMemory(to: GenericView.self)
            return binded.first?.anyView.map { [$0] } ?? []
        }
    }
    
    /// Gets view creators from `Any`. Also splits up `DynamicViewContent` into separate views.
    /// - Parameter view: View of `Any` type.
    /// - Returns: View creators contained by this `view`.
    public static func viewCreators(from view: Any) -> [() -> AnyView] {
        if view is EmptyView {
            return []
        }
        if let forEach = view as? DynamicViewContentProvider {
            return forEach.extractCreators()
        }
        return withUnsafeBytes(of: view) { ptr -> [() -> AnyView] in
            if let genericView = ptr.bindMemory(to: GenericView.self).first {
                return [genericView.anyViewCreator]
            }
            return []
        }
    }
}


// MARK: Content types
public typealias TupleContent<Views> = () -> TupleView<Views>
public typealias NormalContent<Content: View> = () -> Content


// MARK: TupleView views
public extension TupleView {
    var views: [AnyView] {
        let children = Mirror(reflecting: value).children
        return children.flatMap { ViewExtractor.views(from: $0.value) }
    }
    
    var viewCreators: [() -> AnyView] {
        let children = Mirror(reflecting: value).children.map { $0.value }
        return children.flatMap { ViewExtractor.viewCreators(from: $0) }
    }
}


// MARK: Dynamic view content
public protocol DynamicViewContentProvider {
    func extractContent() -> [AnyView]
    func extractCreators() -> [() -> AnyView]
}

extension ForEach: DynamicViewContentProvider where Content: View {
    public func extractContent() -> [AnyView] {
        let mirror = Mirror(reflecting: self)
        
        if let data = mirror.descendant("data") as? Data,
           let content = mirror.descendant("content") as? (Data.Element) -> Content {
            return data.compactMap { element in
                let newContent = content(element)
                if newContent is EmptyView {
                    return nil
                } else {
                    return AnyView(newContent)
                }
            }
        } else {
            return []
        }
    }
    
    public func extractCreators() -> [() -> AnyView] {
        let mirror = Mirror(reflecting: self)
        
        if let data = mirror.descendant("data") as? Data,
           let content = mirror.descendant("content") as? (Data.Element) -> Content {
            return data.compactMap { element in { AnyView(content(element)) } }
        } else {
            return []
        }
    }
}
