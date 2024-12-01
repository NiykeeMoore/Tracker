//
//  CreateCategoryViewController.swift
//  Tracker
//
//  Created by Niykee Moore on 17.11.2024.
//

import UIKit

final class CreateCategoryViewController: UIViewController,
                                          UITextFieldDelegate {
    
    // MARK: - Properties
    var onCategoryCreate: (() -> Void)?
    
    private let viewModel: CategorySelectionViewModel
    
    private lazy var titleViewController: UILabel = {
        let label = UILabel()
        label.text = "Новая категория"
        label.configureLabel(font: .boldSystemFont(ofSize: 16), textColor: .ccBlack, aligment: .center)
        return label
    }()
    
    private let textFieldMaxCharacterLimit = 38
    private lazy var categoryNameField: UITextField = {
        let textField = UITextField()
        textField.delegate = self
        textField.attributedPlaceholder = NSAttributedString(
            string: "Введите название категории",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.ccGray]
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
    private lazy var categoryNameLengthWarning: UILabel = {
        let label = UILabel()
        label.configureLabel(font: .systemFont(ofSize: 17), textColor: .ccRed, aligment: .center)
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()
    
    private lazy var buttonCreateCategory: UIButton = {
        let button = UIButton()
        button.applyCustomStyle(title: "Готово", forState: .normal,
                                titleFont: .systemFont(ofSize: 16), titleColor: .ccWhite, titleColorState: .normal,
                                backgroundColor: .ccBlack,
                                cornerRadius: 16)
        button.addTarget(self, action: #selector(saveNewCategory), for: .touchUpInside)
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
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureConstraints()
        
        viewModel.onCreatedCategoryNameChanged = { [weak self] name in
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
        view.backgroundColor = .ccWhite
        
        [titleViewController, categoryNameField,
         categoryNameLengthWarning, buttonCreateCategory].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        updateCreateTaskButtonstate()
    }
    
    // MARK: - Constraints
    
    private func configureConstraints() {
        NSLayoutConstraint.activate([
            titleViewController.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleViewController.topAnchor.constraint(equalTo: view.topAnchor, constant: 35),
            
            categoryNameField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            categoryNameField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            categoryNameField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            categoryNameField.heightAnchor.constraint(equalToConstant: 75),
            categoryNameField.topAnchor.constraint(equalTo: titleViewController.bottomAnchor, constant: 38),
            
            categoryNameLengthWarning.topAnchor.constraint(equalTo: categoryNameField.bottomAnchor, constant: 8),
            categoryNameLengthWarning.leadingAnchor.constraint(equalTo: categoryNameField.leadingAnchor),
            categoryNameLengthWarning.trailingAnchor.constraint(equalTo: categoryNameField.trailingAnchor),
            
            buttonCreateCategory.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            buttonCreateCategory.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            buttonCreateCategory.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            buttonCreateCategory.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        warningLabelHeightConstraint = categoryNameLengthWarning.heightAnchor.constraint(equalToConstant: 0)
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
    
    //MARK: - Private Helper Methods
    
    @objc private func textFieldDidChange() {
        viewModel.createdCategoryName = categoryNameField.text ?? ""
    }
    
    private func updateWarningLabel(with message: String?) {
        if let message = message {
            showWarning(message)
        } else {
            hideWarning()
        }
    }
    
    private func showWarning(_ message: String) {
        categoryNameLengthWarning.text = message
        categoryNameLengthWarning.isHidden = false
        warningLabelHeightConstraint?.constant = 20
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func hideWarning() {
        categoryNameLengthWarning.isHidden = true
        warningLabelHeightConstraint?.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func updateCreateTaskButtonstate() {
        buttonCreateCategory.isEnabled = viewModel.isCreateButtonEnabled()
        buttonCreateCategory.backgroundColor = viewModel.isCreateButtonEnabled() ? .ccBlack : .ccGray
    }
    
    //MARK: - Actions
    
    @objc private func saveNewCategory() {
        viewModel.createCategory()
        onCategoryCreate?()
        dismiss(animated: true, completion: nil)
    }
}
