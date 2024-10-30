//
//  TypeSelectionViewController.swift
//  Tracker
//
//  Created by Niykee Moore on 01.10.2024.
//

import UIKit

class TypeSelectionViewController: UIViewController {
    
    // MARK: - Properties
    
    var onClose: (() -> Void)?
    var onTaskCreated: ((String, Task) -> Void)?
    
    private lazy var titleViewController: UILabel = {
        let label = UILabel()
        label.text = "Создание трекера"
        label.configureLabel(font: .systemFont(ofSize: 16), textColor: .ccBlack, aligment: .center)
        return label
    }()
    
    private lazy var habitButton: UIButton = {
        return configureCategoryButton(withTitle: "Привычка", selector: #selector(setHabitCategory))
    }()
    
    private lazy var irregularEventButton: UIButton = {
        return configureCategoryButton(withTitle: "Нерегулярное событие", selector: #selector(setIrregularEventCategory))
    }()
    
    private lazy var selectionStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureConstraints()
    }
    
    // MARK: - UI Setup
    
    private func configureUI() {
        view.backgroundColor = .white
        [titleViewController, selectionStackView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        selectionStackView.addArrangedSubview(habitButton)
        selectionStackView.addArrangedSubview(irregularEventButton)
    }
    
    // MARK: - Constraints
    
    private func configureConstraints() {
        NSLayoutConstraint.activate([
            titleViewController.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleViewController.topAnchor.constraint(equalTo: view.topAnchor, constant: 35),
            
            selectionStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            selectionStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            selectionStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            selectionStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            habitButton.heightAnchor.constraint(equalToConstant: 60),
            irregularEventButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    // MARK: - Private Helper Methods
    
    private func configureCategoryButton(withTitle title: String, selector: Selector) -> UIButton {
        let button = UIButton()
        button.applyCustomStyle(title: title, forState: .normal,
                                titleFont: .boldSystemFont(ofSize: 16),
                                titleColor: .white, titleColorState: .normal,
                                backgroundColor: .ccBlack, cornerRadius: 16)
        button.addTarget(self, action: selector, for: .touchUpInside)
        return button
    }
    
    private func openCreateTaskViewController(viewModel: CreateTaskViewModel) {
        let createTaskVC = CreateTaskViewController(viewModel: viewModel)
        
        createTaskVC.onTaskCreated = { [weak self] (category, newTask) in
            guard let self else { return }
            self.onTaskCreated?(category, newTask)
        }
        createTaskVC.onClose = { [weak self] in
            guard let self else { return }
            self.onClose?()
        }
        
        present(createTaskVC, animated: true)
    }
    
    // MARK: - Actions
    
    @objc private func setHabitCategory() {
        openCreateTaskViewController(viewModel: CreateTaskViewModel(taskType: .habit))
    }
    
    @objc private func setIrregularEventCategory() {
        openCreateTaskViewController(viewModel: CreateTaskViewModel(taskType: .irregularEvent))
    }
}
