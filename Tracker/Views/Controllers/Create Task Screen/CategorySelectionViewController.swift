//
//  SetHabitViewController.swift
//  Tracker
//
//  Created by Niykee Moore on 08.10.2024.
//

import UIKit

final class CategorySelectionViewController: UIViewController {
    
    //MARK: - Properties
    
    private lazy var titleViewController: UILabel = {
        let label = UILabel()
        label.configureLabel(font: .boldSystemFont(ofSize: 16), textColor: .ccBlack, aligment: .center)
        label.text = "Категория"
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var placeholderImage: UIImageView = {
        let image = UIImage(named: "placeholderTrackerList")
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let placeholderLabel = UILabel()
        placeholderLabel.text = "Привычки и события можно объединить по смыслу"
        placeholderLabel.configureLabel(font: .boldSystemFont(ofSize: 12), textColor: .ccBlack, aligment: .center)
        return placeholderLabel
    }()
    
    private lazy var createCategoryButton:  UIButton = {
        let button = UIButton()
        button.applyCustomStyle(title: "Добавить категорию", forState: .normal, titleFont: .boldSystemFont(ofSize: 16),
                                titleColor: .white, titleColorState: .normal,
                                backgroundColor: .ccBlack,
                                cornerRadius: 16)
        return button
    }()
    
    //MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureUI()
        configureConstraints()
    }
    
    // MARK: - UI Setup
    
    private func configureUI() {
        [titleViewController, placeholderImage,
         placeholderLabel,createCategoryButton].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    // MARK: - Constraints
    
    private func configureConstraints() {
        NSLayoutConstraint.activate([
            titleViewController.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleViewController.topAnchor.constraint(equalTo: view.topAnchor, constant: 35),
            
            placeholderImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            placeholderImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImage.widthAnchor.constraint(equalToConstant: 80),
            placeholderImage.heightAnchor.constraint(equalToConstant: 80),
            
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImage.bottomAnchor, constant: 8),
            placeholderLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            placeholderLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            placeholderLabel.heightAnchor.constraint(equalToConstant: 18),
            
            createCategoryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            createCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            createCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createCategoryButton.heightAnchor.constraint(equalToConstant: 60),
            createCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
}
