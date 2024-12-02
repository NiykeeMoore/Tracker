//
//  CreateHabitViewController.swift
//  Tracker
//
//  Created by Niykee Moore on 01.10.2024.
//

import UIKit

final class CreateTaskViewController: UIViewController,
                                      UITextFieldDelegate,
                                      UICollectionViewDelegateFlowLayout, UICollectionViewDataSource,
                                      UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Properties
    
    var onTaskSaved: (() -> Void)?
    var onClose: (() -> Void)?
    var onTaskEdited: (() -> Void)?
    
    private let viewModel: CreateTaskViewModel
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .interactive
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var titleViewController: UILabel = {
        let label = UILabel()
        label.configureLabel(font: .boldSystemFont(ofSize: 16), textColor: .ccBlack, aligment: .center)
        return label
    }()
    
    private let textFieldMaxCharacterLimit = 38
    private lazy var taskNameField: UITextField = {
        let textField = UITextField()
        textField.delegate = self
        textField.attributedPlaceholder = NSAttributedString(
            string: "Введите название трекера",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.ccGray]
        )
        let paddingViewLeft = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.leftView = paddingViewLeft
        textField.leftViewMode = .always
        textField.textColor = .ccBlack
        textField.backgroundColor = .ccLightGray
        textField.clipsToBounds = true
        textField.layer.cornerRadius = 16
        textField.heightAnchor.constraint(equalToConstant: 75).isActive = true
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        return textField
    }()
    
    private var warningLabelHeightConstraint: NSLayoutConstraint? = nil // Для динамического изменения высоты
    private lazy var taskNameLengthWarning: UILabel = {
        let label = UILabel()
        label.configureLabel(font: .systemFont(ofSize: 17), textColor: .ccRed, aligment: .center)
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()
    
    private lazy var onEditDaysRepeatCounterLabel: UILabel = {
        let label = UILabel()
        label.configureLabel(font: .boldSystemFont(ofSize: 32), textColor: .ccBlack, aligment: .center)
        return label
    }()
    
    private lazy var taskDetailsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleViewController, onEditDaysRepeatCounterLabel,
                                                       taskNameField, taskNameLengthWarning])
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 40
        return stackView
    }()
    
    private lazy var collectionViewLayout: UICollectionViewFlowLayout = {
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.minimumLineSpacing = 0
        collectionViewLayout.minimumInteritemSpacing = 0
        return collectionViewLayout
    }()
    
    private lazy var selectionTableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.clipsToBounds = true
        tableView.layer.cornerRadius = 16
        tableView.separatorColor = .ccGray
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.isScrollEnabled = false
        tableView.register(SettingTaskSelectionCell.self, forCellReuseIdentifier: SettingTaskSelectionCell.reuseIdentifier)
        return tableView
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(EmojiCell.self, forCellWithReuseIdentifier: EmojiCell.reuseIdentifier)
        collectionView.register(ColorCell.self, forCellWithReuseIdentifier: ColorCell.reuseIdentifier)
        collectionView.register(SectionHeaderCollectionView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeaderCollectionView.trackerHeaderIdentifier)
        collectionView.allowsMultipleSelection = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    private lazy var buttonCancelCreation: UIButton = {
        return configureButton(withTitle: "Отменить", setType: .system, selector: #selector(cancelCreation))
    }()
    
    private lazy var buttonCreateTask: UIButton = {
        return configureButton(withTitle: "Создать", setType: .custom, selector: #selector(createTask))
    }()
    
    private lazy var stackViewButtons: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [buttonCancelCreation, buttonCreateTask])
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        stackView.spacing = 8
        return stackView
    }()
    
    // MARK: - Initialization
    
    init(viewModel: CreateTaskViewModel, editingTask: Tracker?, completedDays: Int?, taskCategory: String?) {
        self.viewModel = viewModel
        self.viewModel.editingTask = editingTask
        self.viewModel.completedDays = completedDays
        self.viewModel.taskCategory = taskCategory
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureConstraints()
        
        viewModel.onTaskNameChanged = { [weak self] name in
            guard let self else { return }
            self.updateCreateTaskButtonstate()
        }
        
        viewModel.onWarningMessageChanged = { [weak self] message in
            guard let self else { return }
            self.updateWarningLabel(with: message)
        }
        
        viewModel.onCategoryChanged = { [weak self] selectedCategory in
            guard let self = self else { return }
            let indexPath = IndexPath(row: 0, section: 0)
            self.selectionTableView.reloadRows(at: [indexPath], with: .none)
        }
        
        viewModel.onScheduleChanged = { [weak self] newDescription in
            guard let self = self else { return }
            let indexPath = IndexPath(row: 1, section: 0)
            self.selectionTableView.reloadRows(at: [indexPath], with: .none)
        }
    }
    
    // MARK: - UI Setup
    
    private func configureUI() {
        view.backgroundColor = .ccWhite
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [taskDetailsStackView, selectionTableView,
         collectionView, stackViewButtons].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        updateOnEditDaysRepeatCounterVisibility(isVisible: false)
        
        switch viewModel.taskType {
        case .habit:
            titleViewController.text = "Новая привычка"
        case .irregularEvent:
            titleViewController.text = "Новое нерегулярное событие"
        case .underEditing:
            titleViewController.text = "Редактирование привычки"
            updateOnEditDaysRepeatCounterVisibility(isVisible: true)
            setupEditingData()
        }
        
        collectionView.layoutIfNeeded()
        updateCreateTaskButtonstate()
    }
    
    // MARK: - Constraints
    
    private func configureConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            taskDetailsStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            taskDetailsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            taskDetailsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            taskDetailsStackView.bottomAnchor.constraint(equalTo: selectionTableView.topAnchor, constant: -32),
            
            selectionTableView.topAnchor.constraint(equalTo: taskDetailsStackView.bottomAnchor, constant: 32),
            selectionTableView.leadingAnchor.constraint(equalTo: taskNameField.leadingAnchor),
            selectionTableView.trailingAnchor.constraint(equalTo: taskNameField.trailingAnchor),
            
            collectionView.topAnchor.constraint(equalTo: selectionTableView.bottomAnchor, constant: 32),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: stackViewButtons.topAnchor, constant: -16),
            collectionView.heightAnchor.constraint(equalToConstant: calculateCollectionViewHeight()),
            
            stackViewButtons.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stackViewButtons.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stackViewButtons.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            stackViewButtons.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        let rowHeight: CGFloat = 75
        let numberOfRows = CGFloat(getNumberOfRowsInSection())
        selectionTableView.heightAnchor.constraint(equalToConstant: numberOfRows * rowHeight).isActive = true
        
        warningLabelHeightConstraint = taskNameLengthWarning.heightAnchor.constraint(equalToConstant: 0)
        warningLabelHeightConstraint?.isActive = true
    }
    
    // MARK: - UITextFieldDelegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let currentText = textField.text else { return true }
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        viewModel.updateWarningMessage(for: newText, limit: textFieldMaxCharacterLimit)
        return newText.count <= textFieldMaxCharacterLimit
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - UITTableViewDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getNumberOfRowsInSection()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingTaskSelectionCell.reuseIdentifier,
                                                       for: indexPath) as? SettingTaskSelectionCell else {
            return UITableViewCell()
        }
        
        let title = viewModel.selectionButtonTitles[indexPath.row]
        let description = viewModel.setSelectionButtonsDescription(at: indexPath.row)
        cell.renderCell(title: title, description: description)
        
        if indexPath.row == getNumberOfRowsInSection() - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        }
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        if indexPath.row == 0 {
            let setCategoryVC = CategorySelectionViewController(viewModel: CategorySelectionViewModel(), selectedCategory: viewModel.taskCategory)
            
            setCategoryVC.onCategorySelected = { [weak self] category in
                guard let self else { return }
                self.viewModel.taskCategory = category
                self.updateCreateTaskButtonstate()
            }
            
            present(setCategoryVC, animated: true)
        } else {
            let setSheduleVC = ScheduleSelectionViewController(viewModel: CreateTaskViewModel(taskType: viewModel.taskType))
            
            setSheduleVC.setSchedule = { [weak self] someDays in
                guard let self else { return }
                self.viewModel.taskSchedule = someDays
                self.updateCreateTaskButtonstate()
            }
            
            present(setSheduleVC, animated: true)
        }
    }
    
    // MARK: - UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.collectionViewSectionHeaders.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? viewModel.emojisInSection.count : viewModel.colorsInSection.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            let emojiCell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCell.reuseIdentifier, for: indexPath) as! EmojiCell
            let isSelected = viewModel.selectedEmojiIndex == indexPath.item
            emojiCell.configure(with: viewModel.emojisInSection[indexPath.item], isSelected: isSelected)
            return emojiCell
        case 1:
            let colorCell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCell.reuseIdentifier, for: indexPath) as! ColorCell
            let isSelected = viewModel.selectedColorIndex == indexPath.item
            colorCell.configure(with: viewModel.colorsInSection[indexPath.item], isSelected: isSelected)
            return colorCell
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeaderCollectionView.trackerHeaderIdentifier, for: indexPath) as! SectionHeaderCollectionView
        header.createHeader(with: viewModel.collectionViewSectionHeaders[indexPath.section])
        return header
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsPerRow: CGFloat = 7
        let padding: CGFloat = (itemsPerRow - 1) * 5
        let availableWidth = UIScreen.main.bounds.width - padding
        let widthPerItem = availableWidth / itemsPerRow
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 19)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        
        if indexPath.section == 0 {
            if let selectedEmoji = viewModel.selectedEmojiIndex {
                if let previousCell = collectionView.cellForItem(at: IndexPath(item: selectedEmoji, section: indexPath.section)) as? EmojiCell {
                    previousCell.configure(with: viewModel.emojisInSection[selectedEmoji], isSelected: false)
                }
            }
            
            if let cell = collectionView.cellForItem(at: indexPath) as? EmojiCell {
                cell.configure(with: viewModel.emojisInSection[indexPath.item], isSelected: true)
            }
            viewModel.selectedEmojiIndex = indexPath.item
        } else {
            if let selectedColor = viewModel.selectedColorIndex {
                if let previousCell = collectionView.cellForItem(at: IndexPath(item: selectedColor, section: indexPath.section)) as? ColorCell {
                    previousCell.configure(with: viewModel.colorsInSection[selectedColor], isSelected: false)
                }
            }
            
            if let cell = collectionView.cellForItem(at: indexPath) as? ColorCell {
                cell.configure(with: viewModel.colorsInSection[indexPath.item], isSelected: true)
            }
            viewModel.selectedColorIndex = indexPath.item
        }
        updateCreateTaskButtonstate()
    }
    
    //MARK: - Private Helper Methods
    
    @objc private func textFieldDidChange() {
        viewModel.taskName = taskNameField.text ?? ""
    }
    
    private func updateWarningLabel(with message: String?) {
        if let message = message {
            showWarning(message)
        } else {
            hideWarning()
        }
    }
    
    private func configureButton(withTitle title: String, setType type: UIButton.ButtonType, selector: Selector) -> UIButton {
        let button = UIButton(type: type)
        
        switch type {
        case .system:
            button.applyCustomStyle(title: title, forState: .normal,
                                    titleFont: .boldSystemFont(ofSize: 16),
                                    titleColor: .ccRed,
                                    titleColorState: .normal,
                                    backgroundColor: .clear,
                                    cornerRadius: 16)
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.ccRed.cgColor
            button.addTarget(self, action: selector, for: .touchUpInside)
            return button
        default:
            button.applyCustomStyle(title: title,
                                    forState: .normal,
                                    titleFont: .boldSystemFont(ofSize: 16),
                                    titleColor: .ccWhite,
                                    titleColorState: .normal,
                                    backgroundColor: .ccGray,
                                    cornerRadius: 16)
            button.addTarget(self, action: selector, for: .touchUpInside)
            return button
        }
    }
    
    private func showWarning(_ message: String) {
        taskNameLengthWarning.text = message
        taskNameLengthWarning.isHidden = false
        warningLabelHeightConstraint?.constant = 20
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func hideWarning() {
        taskNameLengthWarning.isHidden = true
        warningLabelHeightConstraint?.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func updateCreateTaskButtonstate() {
        buttonCreateTask.isEnabled = viewModel.isCreateButtonEnabled()
        buttonCreateTask.backgroundColor = viewModel.isCreateButtonEnabled() ? .ccBlack : .ccGray
    }
    
    private func getNumberOfRowsInSection() -> Int {
        switch viewModel.taskType {
        case .habit, .underEditing:
            return viewModel.selectionButtonTitles.count
        case .irregularEvent:
            return viewModel.selectionButtonTitles.dropLast().count
        }
    }
    
    private func calculateCollectionViewHeight() -> CGFloat {
        let numberOfSections = viewModel.collectionViewSectionHeaders.count
        var totalHeight: CGFloat = 0
        let itemsPerRow: CGFloat = 7
        let padding: CGFloat = 5
        
        for section in 0..<numberOfSections {
            let itemsInSection = section == 0 ? viewModel.emojisInSection.count : viewModel.colorsInSection.count
            let rows = ceil(CGFloat(itemsInSection) / itemsPerRow) // Округление вверх
            let rowHeight = (UIScreen.main.bounds.width - (padding * (itemsPerRow - 1))) / itemsPerRow
            totalHeight += rows * rowHeight
        }
        
        totalHeight += CGFloat(numberOfSections * 40) // Высота заголовков секций
        totalHeight += CGFloat((numberOfSections - 1) * 24) // Отступы между секциями
        return totalHeight
    }
    
    private func setupEditingData() {
        viewModel.taskType = .underEditing
        
        if let completedDays = viewModel.completedDays {
            onEditDaysRepeatCounterLabel.text = "\(completedDays) дней"
        }
        
        viewModel.taskName = viewModel.editingTask?.name ?? "test name"
        taskNameField.text = viewModel.taskName
        
        viewModel.taskSchedule = viewModel.editingTask?.schedule
        
        if let emoji = viewModel.editingTask?.emoji {
            let emojiIndex = viewModel.emojisInSection.firstIndex(of: emoji)
            viewModel.selectedEmojiIndex = emojiIndex
        }
        
        if let color = viewModel.editingTask?.color.toHexString() {
            let colorsInSectionInHex = viewModel.colorsInSection.map { $0.toHexString() }
            let selectedColor = colorsInSectionInHex.firstIndex(of: color)
            viewModel.selectedColorIndex = selectedColor
        }
    }
    
    private func updateOnEditDaysRepeatCounterVisibility(isVisible: Bool) {
        onEditDaysRepeatCounterLabel.isHidden = !isVisible
        taskDetailsStackView.setCustomSpacing(isVisible ? 16 : 0, after: titleViewController)
    }
    
    //MARK: - Actions
    
    @objc private func createTask() {
        viewModel.saveTask()
        onTaskSaved?()
        if viewModel.taskType == .underEditing { dismiss(animated: true) }
        onClose?()
    }
    
    @objc private func cancelCreation() {
        onClose?()
    }
}
