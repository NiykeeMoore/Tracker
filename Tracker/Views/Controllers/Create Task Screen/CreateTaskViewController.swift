//
//  CreateHabitViewController.swift
//  Tracker
//
//  Created by Niykee Moore on 01.10.2024.
//

import UIKit

class CreateTaskViewController: UIViewController,
                                UITextFieldDelegate,
                                UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    // MARK: - Properties
    
    private let viewModel: CreateTaskViewModel
    
    var onTaskCreated: ((String, Task) -> Void)?
    var onClose: (() -> Void)?
    
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
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.ccBlack]
        )
        let paddingViewLeft = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.leftView = paddingViewLeft
        textField.leftViewMode = .always
        textField.textColor = .ccBlack
        textField.backgroundColor = .ccLightGray
        textField.clipsToBounds = true
        textField.layer.cornerRadius = 16
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
    
    private lazy var collectionViewLayout: UICollectionViewFlowLayout = {
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.scrollDirection = .vertical
        collectionViewLayout.minimumLineSpacing = 0
        return collectionViewLayout
    }()
    
    private lazy var selectionStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 2
        stackView.distribution = .fillEqually
        stackView.layer.cornerRadius = 16
        stackView.clipsToBounds = true
        return stackView
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
    
    init(viewModel: CreateTaskViewModel) {
        self.viewModel = viewModel
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
    }
    
    // MARK: - UI Setup
    
    private func configureUI() {
        view.backgroundColor = .white
        
        [titleViewController, taskNameField, taskNameLengthWarning,
         selectionStackView, collectionView, stackViewButtons].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        configureStackView()
        titleViewController.text = viewModel.taskType == .habit ? "Новая привычка" : "Новое нерегулярное событие"
        collectionView.layoutIfNeeded()
    }
    
    private func configureStackView() {
        let titles = viewModel.taskType == .irregularEvent ?
        viewModel.selectionButtonTitles.dropLast() :
        viewModel.selectionButtonTitles
        
        for (index, title) in titles.enumerated() {
            let container = createSelectionContainer(with: title, tag: index)
            selectionStackView.addArrangedSubview(container)
        }
    }
    
    // MARK: - Constraints
    
    private func configureConstraints() {
        NSLayoutConstraint.activate([
            titleViewController.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleViewController.topAnchor.constraint(equalTo: view.topAnchor, constant: 35),
            
            taskNameField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            taskNameField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            taskNameField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            taskNameField.heightAnchor.constraint(equalToConstant: 75),
            taskNameField.topAnchor.constraint(equalTo: titleViewController.bottomAnchor, constant: 38),
            
            taskNameLengthWarning.topAnchor.constraint(equalTo: taskNameField.bottomAnchor, constant: 8),
            taskNameLengthWarning.leadingAnchor.constraint(equalTo: taskNameField.leadingAnchor),
            taskNameLengthWarning.trailingAnchor.constraint(equalTo: taskNameField.trailingAnchor),
            
            selectionStackView.topAnchor.constraint(equalTo: taskNameLengthWarning.bottomAnchor, constant: 32),
            selectionStackView.leadingAnchor.constraint(equalTo: taskNameField.leadingAnchor),
            selectionStackView.trailingAnchor.constraint(equalTo: taskNameField.trailingAnchor),
            
            collectionView.topAnchor.constraint(equalTo: selectionStackView.bottomAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: stackViewButtons.topAnchor, constant: -16),
            
            stackViewButtons.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            stackViewButtons.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            stackViewButtons.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            stackViewButtons.heightAnchor.constraint(equalToConstant: 60)
        ])
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
            emojiCell.configure(with: viewModel.emojisInSection[indexPath.item], isSelected: false)
            return emojiCell
        case 1:
            let colorCell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCell.reuseIdentifier, for: indexPath) as! ColorCell
            colorCell.configure(with: viewModel.colorsInSection[indexPath.item], isSelected: false)
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
        return CGSize(width: 40, height: 40)
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
                                    titleColor: .white,
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
    
    private func createSelectionContainer(with title: String, tag index: Int) -> UIView {
        let container = UIView()
        container.backgroundColor = .ccLightGray
        
        let selectionButtonTitle = UILabel()
        selectionButtonTitle.configureLabel(font: .systemFont(ofSize: 17), textColor: .ccBlack, aligment: nil)
        selectionButtonTitle.text = title
        
        let selectionButtonDescription = UILabel()
        selectionButtonDescription.configureLabel(font: .systemFont(ofSize: 17), textColor: .ccGray, aligment: nil)
        
        let detailDisclosure = UIButton(type: .system)
        let chevonImage = UIImage(systemName: "chevron.right")
        detailDisclosure.setImage(chevonImage, for: .normal)
        detailDisclosure.tintColor = .ccGray
        detailDisclosure.tag = index
        detailDisclosure.addTarget(self, action: #selector(detailDisclosureTapped), for: .touchUpInside)
        
        [selectionButtonTitle, selectionButtonDescription, detailDisclosure].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            selectionButtonTitle.topAnchor.constraint(equalTo: container.topAnchor, constant: 15),
            selectionButtonTitle.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            
            selectionButtonDescription.topAnchor.constraint(equalTo: selectionButtonTitle.bottomAnchor, constant: -2),
            selectionButtonDescription.leadingAnchor.constraint(equalTo: selectionButtonTitle.leadingAnchor),
            selectionButtonDescription.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -14),
            
            detailDisclosure.topAnchor.constraint(equalTo: container.topAnchor, constant: 26),
            detailDisclosure.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -26),
            detailDisclosure.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16)
        ])
        
        viewModel.onSelectionDescriptionChanged = { [weak selectionButtonDescription] text in
            selectionButtonDescription?.text = text
        }
        
        return container
    }
    
    //MARK: - Actions
    
    @objc private func detailDisclosureTapped(_ sender: UIButton) {
        if sender.tag == 0 {
            present(CategorySelectionViewController(), animated: true)
        } else {
            let setSheduleVC = ScheduleSelectionViewController()
            present(setSheduleVC, animated: true)
            
            setSheduleVC.setSchedule = { [weak self] someDays in
                guard let self else { return }
                self.viewModel.taskSchedule = someDays
                let description = "\(self.viewModel.convertWeekdays(weekdays: someDays))"
                self.viewModel.selectionDescription = description
                self.updateCreateTaskButtonstate()
            }
        }
    }
    
    @objc private func createTask() {
        if let newTask = viewModel.createTask() {
            onTaskCreated?(viewModel.getSelectedCategory(), newTask)
            onClose?()
        }
    }
    
    @objc private func cancelCreation() {
        onClose?()
    }
}