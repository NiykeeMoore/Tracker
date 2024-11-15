//
//  ViewController.swift
//  Tracker
//
//  Created by Niykee Moore on 26.09.2024.
//

import UIKit

final class TaskListViewController: UIViewController, UISearchBarDelegate,
                                    UICollectionViewDelegateFlowLayout, UICollectionViewDataSource  {
    //MARK: - Properties
    
    private let viewModel: TaskListViewModel
    
    private lazy var taskDatePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.tintColor = .ccBlue
        datePicker.maximumDate = Date()
        datePicker.clipsToBounds = true
        datePicker.layer.cornerRadius = 8
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        return datePicker
    }()
    
    private lazy var searchController = UISearchController(searchResultsController: nil)
    
    private lazy var placeholderImage: UIImageView = {
        let image = UIImage(named: "placeholderTrackerList")
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let placeholderLabel = UILabel()
        placeholderLabel.text = "Что будем отслеживать?"
        placeholderLabel.configureLabel(font: .boldSystemFont(ofSize: 12), textColor: .ccBlack, aligment: .center)
        return placeholderLabel
    }()
    
    private lazy var collectionViewLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 9
        layout.sectionInsetReference = .fromContentInset
        layout.sectionInset = UIEdgeInsets(top: 36, left: 0, bottom: 0, right: 0)
        return layout
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.register(TaskCell.self, forCellWithReuseIdentifier: TaskCell.reuseIdentifier)
        collectionView.register(SectionHeaderCollectionView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeaderCollectionView.trackerHeaderIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.allowsMultipleSelection = false
        return collectionView
    }()
    
    // MARK: - Initialization
    
    init(viewModel: TaskListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureSearchBar()
        configureConstraints()
        
        viewModel.onDataGetChanged = { [weak self] in
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }
    }
    
    // MARK: - UI Setup
    
    private func configureUI() {
        view.backgroundColor = .white
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: taskDatePicker)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"),
                                                           style: .done,
                                                           target: self,
                                                           action: #selector (buttonCreateTracker))
        navigationItem.searchController = searchController
        [taskDatePicker, collectionView, placeholderImage, placeholderLabel].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    // MARK: - Constraints
    
    private func configureConstraints() {
        NSLayoutConstraint.activate([
            taskDatePicker.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            taskDatePicker.widthAnchor.constraint(equalToConstant: 97),
            taskDatePicker.heightAnchor.constraint(equalToConstant: 34),
            
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            placeholderImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            placeholderImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImage.widthAnchor.constraint(equalToConstant: 80),
            placeholderImage.heightAnchor.constraint(equalToConstant: 80),
            
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImage.bottomAnchor, constant: 8),
            placeholderLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            placeholderLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            placeholderLabel.heightAnchor.constraint(equalToConstant: 18)
        ])
    }
    
    // MARK: - Search Bar Configuration
    
    private func configureSearchBar() {
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.searchTextField.leftView?.tintColor = .ccBlack
        searchController.searchBar.searchTextField.textColor = .ccBlack
        searchController.searchBar.tintColor = .ccBlack
        searchController.searchBar.searchTextField.attributedPlaceholder = NSAttributedString(
            string: "Поиск",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.ccBlack]
        )
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
    }
    
    // MARK: - UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.numberOfSections()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItems(in: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TaskCell.reuseIdentifier, for: indexPath) as? TaskCell
        else { return UICollectionViewCell() }
        
        let tasksForSelectedDay = viewModel.fetchTasksForDate(viewModel.selectedDay)
        let task = tasksForSelectedDay[indexPath.item]
        
        let isCompleted = viewModel.isTaskCompleted(for: task, on: viewModel.selectedDay)
        cell.updateButtonImage(isCompleted: isCompleted)
        
        let completedDaysCount = viewModel.completedDaysCount(for: task.id)
        cell.updateDayCountLabel(with: completedDaysCount)
        cell.configure(with: task)
        
        viewModel.onCompletedDaysCountUpdated = { [weak self, weak cell] in
            guard let self = self, let cell = cell else { return }
            
            let updatedCount = self.viewModel.completedDaysCount(for: task.id)
            cell.updateDayCountLabel(with: updatedCount)
        }
        
        cell.onCompleteTaskButtonTapped = { [weak self] in
            guard let self = self else { return }
            self.viewModel.toggleCompletionStatus(task, on: self.viewModel.selectedDay)
            cell.updateButtonImage(isCompleted: self.viewModel.isTaskCompleted(for: task, on: self.viewModel.selectedDay))
            
            let updatedCount = self.viewModel.completedDaysCount(for: task.id)
            cell.updateDayCountLabel(with: updatedCount)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeaderCollectionView.trackerHeaderIdentifier, for: indexPath) as! SectionHeaderCollectionView
        guard let fetchedHeaders = viewModel.fetchAllCategories() else { return UICollectionReusableView() }
        header.createHeader(with: fetchedHeaders[indexPath.section].title)
        return header
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if viewModel.hasTasksForToday(in: section) {
            activePlaceholderImage(isActive: false)
            return CGSize(width: collectionView.bounds.width, height: 18)
        } else {
            activePlaceholderImage(isActive: true)
            return .zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = collectionView.bounds.width / 2 - 20
        return CGSize(width: cellWidth, height: 148)
    }
    
    // MARK: - Private Helper Methods
    
    private func activePlaceholderImage(isActive: Bool) {
        if isActive {
            collectionView.isHidden = true
            placeholderImage.isHidden = false
            placeholderLabel.isHidden = false
        } else {
            collectionView.isHidden = false
            placeholderImage.isHidden = true
            placeholderLabel.isHidden = true
        }
        collectionView.reloadData()
    }
    
    // MARK: - Actions
    
    @objc private func buttonCreateTracker() {
        let typeSelectionVC = TypeSelectionViewController()
        
        typeSelectionVC.onTaskCreated = { [weak self] in
            guard let self else { return }
            self.activePlaceholderImage(isActive: self.viewModel.fetchTasksForDate(viewModel.selectedDay).isEmpty)
        }
        
        typeSelectionVC.onClose = { [weak self] in
            guard let self else { return }
            self.dismiss(animated: true, completion: nil)
        }
        
        present(typeSelectionVC, animated: true)
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        
        viewModel.onSelectedDayChanged = { [weak self] in
            guard let self = self else { return }
            self.activePlaceholderImage(isActive: self.viewModel.fetchTasksForDate(viewModel.selectedDay).isEmpty)
        }
        viewModel.selectedDay = sender.date
    }
}
