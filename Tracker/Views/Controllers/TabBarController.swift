//
//  TabBarController.swift
//  Tracker
//
//  Created by Niykee Moore on 26.09.2024.
//

import UIKit

final class TabBarController: UITabBarController {
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTab()
    }
    
    // MARK: - Private Helper Methods
    
    private func configureTab() {
        tabBar.backgroundColor = .white
        tabBar.unselectedItemTintColor = .ccGray
        tabBar.tintColor = .systemBlue
        tabBar.clipsToBounds = true
        tabBar.layer.borderWidth = 0.5
        tabBar.layer.borderColor = UIColor.ccGray.cgColor
        
        let tasks = self.createNavigationTab(with: "Трекеры", icon: UIImage(systemName: "record.circle.fill")!, viewControler: TaskListViewController(viewModel: TaskListViewModel()))
        let statistics = self.createNavigationTab(with: "Статистика", icon: UIImage(systemName: "hare.fill")!, viewControler: StatisticViewController())
        
        setViewControllers([tasks, statistics], animated: true)
    }
    
    private func createNavigationTab(with title: String, icon image: UIImage, viewControler viewController: UIViewController) -> UINavigationController {
        let navigationBar = UINavigationController(rootViewController: viewController)
        
        navigationBar.tabBarItem.title = title
        navigationBar.tabBarItem.image = image
        navigationBar.viewControllers.first?.navigationItem.title = title
        navigationBar.setupNavigationBarColor(titleTextAttributes: .black, largeTitleTextAttributes: .black)
        return navigationBar
    }
}

