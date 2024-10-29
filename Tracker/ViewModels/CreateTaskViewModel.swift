//
//  CreateTaskViewModel.swift
//  Tracker
//
//  Created by Niykee Moore on 16.10.2024.
//

import UIKit

final class CreateTaskViewModel {
    
    // MARK: - Properties
    
    let collectionViewSectionHeaders: [String] = ["Emoji", "Цвет"]
    let selectionButtonTitles: [String] = ["Категория", "Расписание"]
    var selectionDescription: String? {
        didSet {
            onSelectionDescriptionChanged?(selectionDescription)
        }
    }
    
    var taskType: TaskType
    var taskSchedule: [Weekdays]?
    var taskName: String = "Без названия" {
        didSet {
            onTaskNameChanged?(taskName)
        }
    }
    var selectedEmojiIndex: Int?
    var selectedColorIndex: Int?
    let emojisInSection: [String] = [
        "😊", "😻", "🌸", "🐶", "❤️", "😱",
        "😇", "😡", "🥶", "🤔", "🙌", "🍔",
        "🥦", "🏓", "🏅", "🎸", "🏖", "😪"]
    
    let colorsInSection: [UIColor] = [
        .r1С1Red,       .r1C2Orange,    .r1C3Blue,         .r1C4LightPurple, .r1C5Emerald,    .r1C6DarkPink,
        .r2C1LightPink, .r2C2LightBlue, .r2C3LightGreen,   .r2C4DarkPurple,  .r2C5DarkOrange, .r2C6Pink,
        .r3C1Sandy,     .r3C2Сornflower,.r3C3Purple,       .r3C4DarkPink,    .r3C5ApsidBlue,  .r3C6LimeGreen
    ]
    
    private(set) var warningMessage: String? {
        didSet {
            onWarningMessageChanged?(warningMessage)
        }
    }
    private var currentDate: Date {
        return Date()
    }
    
    var onTaskCreated: ((Task) -> Void)?
    var onSectionsUpdated: (() -> Void)?
    var onTaskNameChanged: ((String?) -> Void)?
    var onWarningMessageChanged: ((String?) -> Void)?
    var onSelectionDescriptionChanged: ((String?) -> Void)?
    
    // MARK: - Initialization
    
    init(taskType: TaskType) {
        self.taskType = taskType
    }
    
    // MARK: - Public Helper Methods
    
    func getSelectedCategory() -> String {
        return "KEK"
    }
    
    func getTaskSchedule() -> [Weekdays]? {
        if taskType == .irregularEvent {
            let currentWeekday = getDayOfWeek(from: currentDate)
            taskSchedule = [currentWeekday]
        }
        return taskSchedule
    }
    
    func createTask() -> Task? {
        guard isReadyToCreateTask() else { return nil }
        
        return Task(id: UUID(),
                    name: taskName,
                    taskType: taskType,
                    color: colorsInSection[selectedColorIndex!],
                    emoji: emojisInSection[selectedEmojiIndex!],
                    schedule: getTaskSchedule(),
                    creationDate: Date())
    }
    
    func isCreateButtonEnabled() -> Bool {
        return isReadyToCreateTask()
    }
    
    func updateWarningMessage(for text: String, limit: Int) {
        if text.count > limit {
            warningMessage = "Ограничение \(limit) символов"
        } else {
            warningMessage = nil
        }
    }
    
    func convertWeekdays(weekdays: [Weekdays]) -> String {
        let allDays = Weekdays.allCases.map { $0 }
        let missingDays = allDays.filter { !weekdays.contains($0) }
        
        switch weekdays.count {
        case 7:
            return "Каждый день"
        case 5...6:
            return "Каждый день, кроме \(cutTheDay(days: missingDays))"
        default:
            return cutTheDay(days: weekdays)
        }
    }
    
    // MARK: - Private Helper Methods
    
    private func isReadyToCreateTask() -> Bool {
        if taskType == .irregularEvent {
            return !taskName.isEmpty && selectedEmojiIndex != nil && selectedColorIndex != nil
        }
        return !taskName.isEmpty && taskSchedule != nil && selectedEmojiIndex != nil && selectedColorIndex != nil
    }
    
    private func cutTheDay(days: [Weekdays]) -> String {
        return days.map { day in
            switch Weekdays(rawValue: day.rawValue) {
            case .monday: return "Пн"
            case .tuesday: return "Вт"
            case .wednesday: return "Ср"
            case .thursday: return "Чт"
            case .friday: return "Пт"
            case .saturday: return "Сб"
            case .sunday: return "Вс"
            default: return day.rawValue
            }
        }
        .joined(separator: ", ")
    }
    
    private func getDayOfWeek(from date: Date) -> Weekdays {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        dateFormatter.locale = Locale(identifier: "ru_RU")
        let dayString = dateFormatter.string(from: date).capitalized
        return Weekdays(rawValue: dayString)!
    }
}
