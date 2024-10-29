//
//  UILabel+Extensions.swift
//  Tracker
//
//  Created by Niykee Moore on 07.10.2024.
//

import UIKit

extension UILabel {
    func configureLabel(font: UIFont, textColor: UIColor, aligment: NSTextAlignment?) {
        self.font = font
        self.textColor = textColor
        if let aligment = aligment {
            self.textAlignment = aligment
        }
    }
}
