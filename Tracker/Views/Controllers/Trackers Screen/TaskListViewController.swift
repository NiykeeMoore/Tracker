//
//  ViewController.swift
//  Tracker
//
//  Created by Niykee Moore on 26.09.2024.
//

import UIKit
import AppMetricaCore

final class TaskListViewController: UIViewController, UISearchBarDelegate,
                                    UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource,
                                    AlertPresenterDelegate,
                                    UISearchResultsUpdating,
                                    UIContextMenuInteractionDelegate {
    
    //MARK: - Properties
    
    private let viewModel: TaskListViewModel
    private let userDefaults = UserDefaultsSettings.shared
    private lazy var alertPresenter = AlertPresenter()
    private lazy var placeholder = PlaceholderManager()
    
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
    
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = NSLocalizedString("search_placeholder", comment: "")
        searchController.searchBar.delegate = self
        return searchController
    }()
    
    private lazy var collectionViewLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 9
        layout.sectionInsetReference = .fromContentInset
        layout.sectionInset = UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0)
        return layout
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.register(TaskCell.self, forCellWithReuseIdentifier: TaskCell.reuseIdentifier)
        collectionView.register(SectionHeaderCollectionView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeaderCollectionView.trackerHeaderIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.allowsMultipleSelection = false
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    private lazy var filterButton: UIButton = {
        let item = UIButton()
        item.applyCustomStyle(title: NSLocalizedString("filter_button", comment: ""), forState: .normal, titleFont: .systemFont(ofSize: 17), titleColor: .white, titleColorState: .normal, backgroundColor: .ccBlue, cornerRadius: 16)
        item.clipsToBounds = true
        item.addTarget(self, action: #selector(openFilterViewController), for: .touchUpInside)
        return item
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
        userDefaults.loadPinnedTrackers()
        placeholder.configurePlaceholder(for: view, type: .taskList, isActive: viewModel.fetchTasksForDate(viewModel.selectedDay).isEmpty)
        
        viewModel.onDataGetChanged = { [weak self] in
            guard let self else { return }
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
        
        alertPresenter.delegate = self
    }
    
    // MARK: - UI Setup
    
    private func configureUI() {
        view.backgroundColor = .ccWhite
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: taskDatePicker)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"),
                                                           style: .done,
                                                           target: self,
                                                           action: #selector (buttonCreateTracker))
        navigationItem.searchController = searchController
        [taskDatePicker, collectionView, filterButton].forEach {
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
            
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            filterButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 130),
            filterButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -130),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filterButton.heightAnchor.constraint(equalToConstant: 50)
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
            string: NSLocalizedString("search_placeholder", comment: ""),
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.ccBlack]
        )
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
    }
    
    // MARK: - UISearchResultsUpdating
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased() else { return }
        
        if !searchText.isEmpty {
            viewModel.selectedFilter = .onSearch
            viewModel.applyFilter(searchText: searchText)
        } else {
            viewModel.selectedFilter = .allTasks
            viewModel.applyFilter(searchText: nil)
        }
        
        if viewModel.selectedFilter == .onSearch {
            placeholder.configurePlaceholder(for: view, type: .taskSearch, isActive: viewModel.categories.isEmpty)
        } else {
            placeholder.configurePlaceholder(for: view, type: .taskList, isActive: viewModel.fetchFilteredTasks(searchText: nil).isEmpty)
        }
        
        viewModel.onDataGetChanged?()
    }
    
    // MARK: - UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.categories[section].tasks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TaskCell.reuseIdentifier, for: indexPath) as? TaskCell
        else { return UICollectionViewCell() }
        
        let task = viewModel.categories[indexPath.section].tasks[indexPath.item]
        
        let isCompleted = viewModel.isTaskCompleted(for: task, on: viewModel.selectedDay)
        cell.updateButtonImage(isCompleted: isCompleted)
        
        cell.updatePinStatus(isPinned: userDefaults.isPinned(trackerId: task.id))
        
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
        header.createHeader(with: viewModel.categories[indexPath.section].title)
        return header
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if viewModel.hasTasksForToday() {
            return CGSize(width: collectionView.bounds.width, height: 18)
        } else {
            return .zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = collectionView.bounds.width / 2 - 20
        return CGSize(width: cellWidth, height: 148)
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(actionProvider: { _ in
            guard let indexPath = indexPaths.first else { return UIMenu() }
            
            let task = self.viewModel.categories[indexPath.section].tasks[indexPath.item]
            let taskCategory = self.viewModel.categories[indexPath.section].title
            let completedDays = self.viewModel.completedDaysCount(for: task.id)
            let titlePinButton = !self.userDefaults.isPinned(trackerId: task.id) ? ContextMenu.attach.rawValue : ContextMenu.deattach.rawValue
            
            return UIMenu(children: [
                UIAction(title: titlePinButton) { [weak self] _ in
                    guard let self else { return }
                    if userDefaults.isPinned(trackerId: task.id) {
                        userDefaults.removePinnedTracker(id: task.id)
                        AppMetrica.reportEvent(name: "TrackerUnpinned", parameters: ["trackerId": task.id.uuidString])
                    } else {
                        userDefaults.addPinnedTracker(id: task.id)
                        AppMetrica.reportEvent(name: "TrackerPinned", parameters: ["trackerId": task.id.uuidString])
                    }
                    
                    self.placeholder.configurePlaceholder(for: self.view, type: .taskList, isActive: self.viewModel.hasTasksForToday())
                },
                UIAction(title: ContextMenu.edit.rawValue) { [weak self] _ in
                    guard let self else { return }
                    AppMetrica.reportEvent(name: "EditTrackerTapped", parameters: ["trackerId": task.id.uuidString])
                    let viewModel = CreateTaskViewModel(taskType: .underEditing)
                    
                    let editVC = CreateTaskViewController(viewModel: viewModel, editingTask: task,
                                                          completedDays: completedDays, taskCategory: taskCategory)
                    
                    editVC.onTaskSaved = { [weak self] in
                        guard let self else { return }
                        self.placeholder.configurePlaceholder(for: self.view, type: .taskList, isActive: self.viewModel.hasTasksForToday())
                    }
                    
                    self.present(editVC, animated: true)
                },
                UIAction(title: ContextMenu.delete.rawValue, attributes: [.destructive]) { [weak self] _ in
                    guard let self else { return }
                    AppMetrica.reportEvent(name: "DeleteTrackerAttempt", parameters: ["trackerId": task.id.uuidString])
                    let buttonDelete = AlertButtonModel(title: "Удалить", style: .destructive) { _ in
                        AppMetrica.reportEvent(name: "DeleteTrackerSuccess", parameters: ["trackerId": task.id.uuidString])
                        StoreManager.shared.trackerStore.remove(tracker: task)
                        self.placeholder.configurePlaceholder(for: self.view, type: .taskList, isActive: self.viewModel.hasTasksForToday())
                    }
                    let buttonCancel = AlertButtonModel(title: "Отмена", style: .cancel) { _ in
                        AppMetrica.reportEvent(name: "DeleteTrackerCanceled", parameters: ["trackerId": task.id.uuidString])
                    }
                    
                    let model = AlertModel(title: "", message: "Уверены что хотите удалить трекер?",
                                           preferredStyle: .actionSheet,
                                           primaryButton: buttonDelete, secondaryButton: buttonCancel)
                    
                    self.alertPresenter.alertPresent(alertModel: model)
                },
            ])
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfiguration configuration: UIContextMenuConfiguration, highlightPreviewForItemAt indexPath: IndexPath) -> UITargetedPreview? {
        guard let cell = collectionView.cellForItem(at: indexPath) as? TaskCell else {
            return nil
        }
        
        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear
        
        return UITargetedPreview(view: cell.themeColorContainer, parameters: parameters)
    }
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return nil
    }
    
    // MARK: - Public Helper Methods
    
    func sendAlert(alert: UIAlertController) {
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Actions
    
    @objc private func buttonCreateTracker() {
        AppMetrica.reportEvent(name: "AddTrackerTapped", parameters: ["screen": "Trackers"])
        let typeSelectionVC = TypeSelectionViewController()
        
        typeSelectionVC.onTaskCreated = { [weak self] in
            guard let self else { return }
            self.placeholder.configurePlaceholder(for: self.view, type: .taskList, isActive: self.viewModel.fetchFilteredTasks(searchText: nil).isEmpty)
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
            self.placeholder.configurePlaceholder(for: self.view, type: .taskList, isActive: self.viewModel.fetchTasksForDate(viewModel.selectedDay).isEmpty)
        }
        AppMetrica.reportEvent(name: "DateChanged", parameters: ["selectedDate": sender.date.description])
        viewModel.selectedDay = sender.date
    }
    
    @objc private func openFilterViewController() {
        AppMetrica.reportEvent(name: "FilterButtonTapped", parameters: ["screen": "Trackers"])
        let filterVC = FilterViewController(viewModel: viewModel)
        
        filterVC.onFilterSelected = { [weak self] in
            guard let self else { return }
            if viewModel.selectedFilter == .tasksForToday {
                taskDatePicker.date = Date()
            }
            self.viewModel.applyFilter(searchText: nil)
        }
        present(filterVC, animated: true)
    }
}
