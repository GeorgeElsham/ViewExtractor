//
//  Extractable.swift
//  
//
//  Created by George Elsham on 17/11/2022.
//

import SwiftUI

protocol Extractable: View {
    associatedtype Content: View
    associatedtype ViewsContent: View

    var content: () -> Content { get }
    var views: (Views) -> ViewsContent { get }

    init(_ content: Content, @ViewBuilder views: @escaping (Views) -> ViewsContent)
    init(@ViewBuilder _ content: @escaping () -> Content, @ViewBuilder views: @escaping (Views) -> ViewsContent)
}

public typealias Views = _VariadicView.Children
