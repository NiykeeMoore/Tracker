//
//  AlertModel.swift
//  Tracker
//
//  Created by Niykee Moore on 28.11.2024.
//

import UIKit

struct AlertModel {
    let title: String
    let message: String
    let preferredStyle: UIAlertController.Style
    let primaryButton: AlertButtonModel
    let secondaryButton: AlertButtonModel?
}

struct AlertButtonModel {
    let title: String
    let style: UIAlertAction.Style
    let handler: ((UIAlertAction) -> Void)?
}
