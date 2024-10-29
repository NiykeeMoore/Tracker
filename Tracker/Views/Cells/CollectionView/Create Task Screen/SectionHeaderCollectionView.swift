//
//  SectionHeaderCollectionView.swift
//  Tracker
//
//  Created by Niykee Moore on 05.10.2024.
//

import UIKit

class SectionHeaderCollectionView: UICollectionReusableView {
    
    //MARK: - Properties
    
    static let trackerHeaderIdentifier = "HeaderTrackerCollectionView"
    
    private lazy var header: UILabel = {
        let label = UILabel()
        label.textColor = .ccBlack
        label.font = .boldSystemFont(ofSize: 19)
        return label
    }()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupHeader()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Helper Methods
    
    func createHeader(with text: String) {
        header.text = text
    }
    
    // MARK: - Private Helper Methods
    
    private func setupHeader() {
        addSubview(header)
        header.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: topAnchor, constant: 22),
            header.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
        ])
    }
}
