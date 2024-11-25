//
//  CategorySelectionCell.swift
//  Tracker
//
//  Created by Niykee Moore on 17.11.2024.
//

import UIKit

final class CategorySelectionCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let reuseIdentifier = "Category Selection Cell"
    
    private lazy var categoryLabel: UILabel = {
        let label = UILabel()
        label.configureLabel(font: .systemFont(ofSize: 17), textColor: .ccBlack, aligment: nil)
        return label
    }()
    
    private lazy var  checkmarkImageView: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(systemName: "checkmark")
        image.tintColor = .systemBlue
        image.isHidden = true
        return image
    }()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        contentView.backgroundColor = .ccLightGray
        backgroundColor = .clear
        [categoryLabel, checkmarkImageView, separatorView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
    }
    
    // MARK: - Constraints
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            categoryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            categoryLabel.trailingAnchor.constraint(equalTo: checkmarkImageView.leadingAnchor),
            categoryLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            checkmarkImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            checkmarkImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 24),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 24),
            
            separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            separatorView.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale)
        ])
    }
    
    //MARK: - Public Helper Methods
    
    func renderCell(with category: String) {
        categoryLabel.text = category
    }
    
    func makeSelected() {
        checkmarkImageView.isHidden = false
    }
    
    func resetSelection() {
        checkmarkImageView.isHidden = true
    }
    
    func getTitle() -> String {
        return categoryLabel.text ?? "Ошибка при получении названия категории"
    }
    
    func showOrHideSeparator(isHidden: Bool) {
        separatorView.isHidden = isHidden
    }
}
