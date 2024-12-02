//
//  PlaceholderView.swift
//  Tracker
//
//  Created by Niykee Moore on 02.12.2024.
//

import UIKit

enum PlaceholderType {
    case taskList
    case taskSearch
    case categoryList
    case statistic
}

final class PlaceholderManager {
    private var placeholderView: UIView?
    
    func configurePlaceholder(for view: UIView, type: PlaceholderType, isActive: Bool) {
        placeholderView?.removeFromSuperview()
        placeholderView = nil
        
        guard isActive else { return }
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .clear
        
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.configureLabel(font: .systemFont(ofSize: 12, weight: .medium), textColor: .ccBlack, aligment: .center)
        
        switch type {
        case .taskList:
            imageView.image = UIImage(named: "placeholderTrackerList")
            label.text = NSLocalizedString("placeholder_title", comment: "")
        case .taskSearch:
            imageView.image = UIImage(named: "placeholderSearchTrackers")
            label.text = NSLocalizedString("nothing_found", comment: "")
        case .categoryList:
            imageView.image = UIImage(named: "placeholderTrackerList")
            label.text = "Привычки и события можно объединить по смыслу"
        case .statistic:
            imageView.image = UIImage(named: "placeholderStatisticList")
            label.text = NSLocalizedString("Анализировать пока нечего", comment: "")
        }
        
        containerView.addSubview(imageView)
        containerView.addSubview(label)
        
        view.addSubview(containerView)
        placeholderView = containerView
        
        NSLayoutConstraint.activate([
            
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.leadingAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            imageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80),
            
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            label.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            label.heightAnchor.constraint(equalToConstant: 18)
        ])
    }
}
