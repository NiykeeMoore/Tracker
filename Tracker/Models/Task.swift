//
//  Tracker.swift
//  Tracker
//
//  Created by Niykee Moore on 01.10.2024.
//

import UIKit

struct Task {
    let id: UUID
    let name: String
    let taskType: TaskType
    let color: UIColor
    let emoji: String
    let schedule: [Weekdays]?
    let creationDate: Date
}
