//
//  TaskListViewModel.swift
//  Tracker
//
//  Created by Niykee Moore on 28.10.2024.
//

import UIKit

final class TaskListViewModel {
    
    // MARK: - Properties
    
    var categories: [TrackerCategory] = [] {
        didSet {
            onCategoriesUpdated?(categories)
        }
    }
    var selectedDay: Date = Date() {
        didSet {
            onSelectedDayChanged?()
        }
    }
    var onSelectedDayChanged: (() -> Void)?
    var onCategoriesUpdated: (([TrackerCategory]) -> Void)?
    var onCurrentDateUpdated: ((Date) -> Void)?
    
    private var tasksCompleted: [TrackerRecord] = []
    private var completedTaskIds: Set<UUID> = []
    private(set) var currentDate: Date = Date() {
        didSet {
            onCurrentDateUpdated?(currentDate)
        }
    }
    
    // MARK: - Public Helper Methods
    
    func listTask(category: String, tracker: Tracker) {
        if let index = categories.firstIndex(where: { $0.title == category }) {
            let updatedTasks = categories[index].tasks + [tracker]
            let updatedCategory = TrackerCategory(title: category, tasks: updatedTasks)
            categories[index] = updatedCategory
        } else {
            categories.append(TrackerCategory(title: category, tasks: [tracker]))
        }
    }
    
    /*
     fixme:
     - Нерегулярная задача будет отображаться в день создания каждый день недели
     */
    func tasksForDate(_ date: Date) -> [Tracker] {
        guard let weekDayToday = getDayOfWeek(from: date) else { return [] }
        
        return categories.flatMap { category in
            category.tasks.filter { task in
                return task.schedule?.contains(weekDayToday) == true
            }
        }
    }
    
    func updateCurrentDate(to date: Date) {
        currentDate = date
    }
    
    func hasTasksForToday(in section: Int) -> Bool {
        return !tasksForDate(currentDate).isEmpty
    }
    
    func isTaskCompleted(_ taskId: UUID, for date: Date) -> Bool {
        return tasksCompleted.contains { $0.id == taskId && Calendar.current.isDate($0.dueDate, inSameDayAs: date) }
    }
    
    func toggleTaskCompletion(_ task: Tracker, on date: Date) {
        if isTaskCompleted(task.id, for: date) {
            unmarkTaskAsCompleted(task, on: date)
        } else {
            markTaskAsCompleted(task, on: date)
        }
    }
    
    func completedDaysCount(for taskId: UUID) -> Int {
        return tasksCompleted.filter { $0.id == taskId }.count
    }
    
    // MARK: - Private Helper Methods
    
    private func getDayOfWeek(from date: Date) -> Weekdays? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        dateFormatter.locale = Locale(identifier: "ru_RU")
        let dayString = dateFormatter.string(from: date).capitalized
        return Weekdays(rawValue: dayString)
    }
    
    private func markTaskAsCompleted(_ task: Tracker, on date: Date) {
        let taskComplete = TrackerRecord(id: task.id, dueDate: date)
        tasksCompleted.append(taskComplete)
        completedTaskIds.insert(task.id)
    }
    
    private func unmarkTaskAsCompleted(_ task: Tracker, on date: Date) {
        tasksCompleted.removeAll { $0.id == task.id && Calendar.current.isDate($0.dueDate, inSameDayAs: date) }
        if !tasksCompleted.contains(where: { $0.id == task.id }) {
            completedTaskIds.remove(task.id)
        }
    }
}
