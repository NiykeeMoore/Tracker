//
//  EmojiCell 2.swift
//  Tracker
//
//  Created by Niykee Moore on 16.10.2024.
//

import UIKit

final class EmojiCell: UICollectionViewCell {
    
    //MARK: - Properties
    
    static let reuseIdentifier = "Emoji Cell"
    
    private lazy var emoji: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 32)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(emoji)
        NSLayoutConstraint.activate([
            emoji.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            emoji.heightAnchor.constraint(equalTo: contentView.heightAnchor),
            emoji.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emoji.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Helper Methods
    
    func configure(with selectedEmoji: String, isSelected: Bool) {
        emoji.text = selectedEmoji
        if isSelected {
            contentView.backgroundColor = .ccEmojiBackground
            contentView.layer.cornerRadius = 16
        } else {
            contentView.backgroundColor = .clear
        }
    }
}
