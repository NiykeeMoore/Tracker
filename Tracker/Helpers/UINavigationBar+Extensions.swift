//
//  UINavigationBar+Extensions.swift
//  Tracker
//
//  Created by Niykee Moore on 26.09.2024.
//

import UIKit

extension UINavigationController {
    
    func createNavigationItem(with title: String, viewControler viewController: UIViewController) -> UINavigationController {
        let navigationBar = UINavigationController(rootViewController: viewController)
        
        navigationBar.tabBarItem.title = title
        navigationBar.setupNavigationBarColor(titleTextAttributes: .white, largeTitleTextAttributes: .white)
        
        return navigationBar
    }
    
    func setupNavigationBarColor(titleTextAttributes cTitle: UIColor, largeTitleTextAttributes cLargeTitle: UIColor) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        appearance.backgroundColor = .white
        
        appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor : cTitle]
        
        appearance.largeTitleTextAttributes = [
            NSAttributedString.Key.foregroundColor : cLargeTitle,
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 34)
        ]
        
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.compactAppearance = appearance
        
        navigationBar.tintColor = .ccBlack
        UIBarButtonItem.appearance().tintColor = .ccBlack
    }
}
