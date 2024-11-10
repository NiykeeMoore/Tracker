//
//  ScheduleSelectionCell.swift
//  Tracker
//
//  Created by Владимир Головин on 30.10.2024.
//

import UIKit

final class ScheduleSelectionCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let reuseIdentifier = "Shedule Cell"
    
    var didChangeSwitchState: ((Bool, Int) -> Void)?
    
    private lazy var dayNameLabel: UILabel = {
        let label = UILabel()
        label.configureLabel(font: .systemFont(ofSize: 17), textColor: .ccBlack, aligment: nil)
        return label
    }()
    
    private lazy var switchButton: UISwitch = {
        let switchButton = UISwitch()
        switchButton.onTintColor = .ccBlue
        switchButton.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
        return switchButton
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
        [dayNameLabel, switchButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
    }
    
    // MARK: - Constraints
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            dayNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            dayNameLabel.trailingAnchor.constraint(equalTo: switchButton.leadingAnchor, constant: -16),
            dayNameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            switchButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            switchButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
    
    //MARK: - Public Helper Methods
    
    func renderCell(with name: String, tag: Int) {
        dayNameLabel.text = name
        switchButton.tag = tag
    }
    
    //MARK: - Actions
    
    @objc private func switchChanged(_ sender: UISwitch) {
        didChangeSwitchState?(sender.isOn, sender.tag)
    }
}
