//
//  UIButton+Extensions.swift
//  Tracker
//
//  Created by Niykee Moore on 07.10.2024.
//

import UIKit

extension UIButton {
    func applyCustomStyle(title: String, forState: UIControl.State, titleFont: UIFont,
                          titleColor: UIColor, titleColorState: UIControl.State,
                          backgroundColor: UIColor,
                          cornerRadius: CGFloat) {
        self.setTitle(title, for: forState)
        self.titleLabel?.font = titleFont
        self.setTitleColor(titleColor, for: titleColorState)
        self.backgroundColor = backgroundColor
        self.layer.cornerRadius = cornerRadius
        if cornerRadius > 0 {
            self.clipsToBounds = true
        }
    }
}
