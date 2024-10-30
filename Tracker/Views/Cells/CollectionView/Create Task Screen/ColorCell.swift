//
//  ColorCell 2.swift
//  Tracker
//
//  Created by Niykee Moore on 16.10.2024.
//

import UIKit

final class ColorCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    static let reuseIdentifier = "Color Cell"
    
    private lazy var mainColorContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var color: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(mainColorContainer)
        NSLayoutConstraint.activate([
            mainColorContainer.widthAnchor.constraint(equalToConstant: 52),
            mainColorContainer.heightAnchor.constraint(equalToConstant: 52),
            mainColorContainer.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            mainColorContainer.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
        mainColorContainer.addSubview(color)
        NSLayoutConstraint.activate([
            color.widthAnchor.constraint(equalToConstant: 40),
            color.heightAnchor.constraint(equalToConstant: 40),
            color.centerXAnchor.constraint(equalTo: mainColorContainer.centerXAnchor),
            color.centerYAnchor.constraint(equalTo: mainColorContainer.centerYAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Helper Methods
    
    func configure(with selectedColor: UIColor, isSelected: Bool) {
        if isSelected {
            mainColorContainer.layer.borderWidth = 3
            mainColorContainer.layer.cornerRadius = 16
            mainColorContainer.layer.borderColor = selectedColor.cgColor.copy(alpha: 0.3)
        } else {
            color.backgroundColor = selectedColor
            mainColorContainer.layer.borderWidth = 0
        }
    }
}
