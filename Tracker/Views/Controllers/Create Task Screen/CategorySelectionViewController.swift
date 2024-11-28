//
//  SetHabitViewController.swift
//  Tracker
//
//  Created by Niykee Moore on 08.10.2024.
//

import UIKit

final class CategorySelectionViewController: UIViewController,
                                             UITableViewDataSource, UITableViewDelegate {
    
    
    //MARK: - Properties
    var onCategorySelected: ((String) -> Void)?
    
    private let viewModel: CategorySelectionViewModel
    private let rowHeight: CGFloat = 75
    private var tableViewHeightConstraint: NSLayoutConstraint?
    
    private lazy var titleViewController: UILabel = {
        let label = UILabel()
        label.configureLabel(font: .boldSystemFont(ofSize: 16), textColor: .ccBlack, aligment: .center)
        label.text = "Категория"
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var categoriesTableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.clipsToBounds = true
        tableView.layer.cornerRadius = 16
        tableView.separatorColor = .clear
        tableView.register(CategorySelectionCell.self, forCellReuseIdentifier: CategorySelectionCell.reuseIdentifier)
        return tableView
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
                                titleColor: .ccWhite, titleColorState: .normal,
                                backgroundColor: .ccBlack,
                                cornerRadius: 16)
        button.addTarget(self, action: #selector(newCategoryButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Initialization
    
    init(viewModel: CategorySelectionViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ccWhite
        viewModel.fetchCategories()
        
        configureUI()
        configureConstraints()
        
        activePlaceholderImage(isActive: viewModel.categoriesList.isEmpty)
        
        viewModel.onCategoriesListUpdated = { [weak self] in
            guard let self else { return }
            DispatchQueue.main.async {
                self.activePlaceholderImage(isActive: self.viewModel.categoriesList.isEmpty)
                self.categoriesTableView.reloadData()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        onCategorySelected?(viewModel.selectedCategory ?? "")
    }
    
    // MARK: - UI Setup
    
    private func configureUI() {
        [titleViewController, placeholderImage,
         placeholderLabel, categoriesTableView, createCategoryButton].forEach {
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
            
            categoriesTableView.topAnchor.constraint(equalTo: titleViewController.bottomAnchor, constant: 38),
            categoriesTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            categoriesTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            categoriesTableView.bottomAnchor.constraint(lessThanOrEqualTo: createCategoryButton.topAnchor, constant: -24),
            
            createCategoryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            createCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            createCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createCategoryButton.heightAnchor.constraint(equalToConstant: 60),
            createCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            
            categoriesTableView.bottomAnchor.constraint(lessThanOrEqualTo: createCategoryButton.topAnchor, constant: -24)
        ])
        updateTableViewHeight()
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.categoriesList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategorySelectionCell.reuseIdentifier,
                                                       for: indexPath) as? CategorySelectionCell else {
            return UITableViewCell()
        }
        
        cell.showOrHideSeparator(isHidden: indexPath.row == viewModel.categoriesList.count - 1)
        cell.renderCell(with: viewModel.categoriesList[indexPath.row])
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        for cell in tableView.visibleCells {
            if let allCells = cell as? CategorySelectionCell {
                allCells.resetSelection()
            }
        }
        
        if let cell = tableView.cellForRow(at: indexPath) as? CategorySelectionCell {
            cell.makeSelected()
            viewModel.selectedCategory = cell.getTitle()
        }
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    // MARK: - Private Helper Methods
    
    private func activePlaceholderImage(isActive: Bool) {
        if isActive {
            categoriesTableView.isHidden = true
            placeholderImage.isHidden = false
            placeholderLabel.isHidden = false
        } else {
            categoriesTableView.isHidden = false
            placeholderImage.isHidden = true
            placeholderLabel.isHidden = true
            updateTableViewHeight()
        }
    }
    
    private func updateTableViewHeight() {
        tableViewHeightConstraint?.isActive = false
        
        let newHeight = CGFloat(viewModel.categoriesList.count) * rowHeight
        tableViewHeightConstraint = categoriesTableView.heightAnchor.constraint(equalToConstant: newHeight)
        tableViewHeightConstraint?.priority = UILayoutPriority(999)
        
        tableViewHeightConstraint?.isActive = true
    }
    
    @objc private func newCategoryButtonTapped() {
        let createCategoryVC = CreateCategoryViewController(viewModel: viewModel)
        
        createCategoryVC.onCategoryCreate = { [weak self] in
            guard let self else { return }
            self.activePlaceholderImage(isActive: self.viewModel.categoriesList.isEmpty)
        }
        
        present(createCategoryVC, animated: true)
    }
}
