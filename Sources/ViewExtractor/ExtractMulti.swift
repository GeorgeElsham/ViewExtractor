//
//  ExtractMulti.swift
//  
//
//  Created by George Elsham on 17/11/2022.
//

import SwiftUI

public struct ExtractMulti<Content: View, ViewsContent: View>: Extractable {
    let content: () -> Content
    let views: (Views) -> ViewsContent

    public init(_ content: Content, @ViewBuilder views: @escaping (Views) -> ViewsContent) {
        self.content = { content }
        self.views = views
    }

    public init(@ViewBuilder _ content: @escaping () -> Content, @ViewBuilder views: @escaping (Views) -> ViewsContent) {
        self.content = content
        self.views = views
    }

    public var body: some View {
        _VariadicView.Tree(
            MultiViewRoot(views: views),
            content: content
        )
    }
}

fileprivate struct MultiViewRoot<Content: View>: _VariadicView_MultiViewRoot {
    let views: (Views) -> Content

    func body(children: Views) -> some View {
        views(children)
    }
}
