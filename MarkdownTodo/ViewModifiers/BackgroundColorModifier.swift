//
//  BackgroundColorModifier.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2020/08/06.
//  Copyright © 2020 Paul Traylor. All rights reserved.
//

import SwiftUI

// Test out answer from https://stackoverflow.com/a/58427754/622650
struct NavigationConfigurator: UIViewControllerRepresentable {
    var configure: (UINavigationController) -> Void = { _ in }

    func makeUIViewController(context: UIViewControllerRepresentableContext<NavigationConfigurator>)
        -> UIViewController
    {
        UIViewController()
    }
    func updateUIViewController(
        _ uiViewController: UIViewController,
        context: UIViewControllerRepresentableContext<NavigationConfigurator>
    ) {
        if let nc = uiViewController.navigationController {
            self.configure(nc)
        }
    }

}

struct BackgroundColorModifier: ViewModifier {
    let color: UIColor

    func body(content: Content) -> some View {
        return content.background(
            NavigationConfigurator { nc in
                nc.navigationBar.barTintColor = color
            })
    }

    init(color: CGColor) {
        self.color = UIColor(cgColor: color)
    }
}
