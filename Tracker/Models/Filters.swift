//
//  Filters.swift
//  Tracker
//
//  Created by Niykee Moore on 28.11.2024.
//

import Foundation

enum Filters: String, CaseIterable {
    case allTasks = "Все трекеры"
    case tasksForToday = "Трекеры на сегодня"
    case completed = "Завершенные"
    case incomplete = "Не завершенные"
    case onSearch = "Поиск"
}
