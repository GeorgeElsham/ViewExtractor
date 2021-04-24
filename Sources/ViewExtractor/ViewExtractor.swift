import SwiftUI


public enum ViewExtractor {
    /// Gets views from a `TupleView`.
    /// - Parameter content: Content to extract the views from.
    /// - Returns: Extracted views.
    public static func getViews<Views>(@ViewBuilder from content: ViewContent<Views>) -> [AnyView] {
        content().getViews
    }
}
