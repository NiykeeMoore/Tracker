//
//  SettingTaskSelectionCell.swift
//  Tracker
//
//  Created by Владимир Головин on 30.10.2024.
//

import UIKit

final class SettingTaskSelectionCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let reuseIdentifier = "Setting Task Cell"
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.configureLabel(font: .systemFont(ofSize: 17), textColor: .ccBlack, aligment: nil)
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.configureLabel(font: .systemFont(ofSize: 17), textColor: .ccGray, aligment: nil)
        return label
    }()
    
    private lazy var detailDisclosureButton: UIButton = {
        let detailDisclosureButton = UIButton(type: .system)
        let chevonImage = UIImage(systemName: "chevron.right")
        detailDisclosureButton.setImage(chevonImage, for: .normal)
        detailDisclosureButton.tintColor = .ccGray
        detailDisclosureButton.isEnabled = false
        return detailDisclosureButton
    }()
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .ccLightGray
        backgroundColor = .clear
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        [titleLabel, descriptionLabel, detailDisclosureButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
    }
    
    // MARK: - Constraints
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: detailDisclosureButton.leadingAnchor, constant: -16),
            titleLabel.bottomAnchor.constraint(equalTo: descriptionLabel.topAnchor, constant: 2),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: -2),
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -14),
            
            detailDisclosureButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 26),
            detailDisclosureButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -26),
            detailDisclosureButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    
    //MARK: - Public Helper Methods
    
    func renderCell(title newTitle: String, description newDescription: String) {
        titleLabel.text = newTitle
        descriptionLabel.text = newDescription
    }
}
