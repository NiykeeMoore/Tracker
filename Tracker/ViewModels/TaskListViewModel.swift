//
//  TaskListViewModel.swift
//  Tracker
//
//  Created by Niykee Moore on 28.10.2024.
//

import UIKit

class TaskListViewModel {
    
    // MARK: - Properties
    
    var categories: [TaskCategory] = []
    private var tasksCompleted: [TasksCompleted] = []
    private var completedTaskIds: Set<UUID> = []
    var currentDate: Date {
        return Date()
    }
    var selectedDay: Date = Date() {
        didSet {
            onSelectedDayChanged?()
        }
    }
    var onSelectedDayChanged: (() -> Void)?
    
    // MARK: - Public Helper Methods
    
    func listTask(category: String, tracker: Task) {
        if let index = categories.firstIndex(where: { $0.title == category }) {
            categories[index].tasks.append(tracker)
        } else {
            categories.append(TaskCategory(title: category, tasks: [tracker]))
        }
    }
    
    func tasksForDate(_ date: Date) -> [Task] {
        let weekDayToday = getDayOfWeek(from: date)
        
        return categories.flatMap { category in
            category.tasks.filter { task in
                switch task.taskType {
                case .irregularEvent:
                    return Calendar.current.isDate(task.creationDate, inSameDayAs: date)
                default:
                    return task.schedule?.contains(weekDayToday!) == true
                }
            }
        }
    }
    
    func hasTasksForToday(in section: Int) -> Bool {
        return !tasksForDate(currentDate).isEmpty
    }
    
    func isTaskCompleted(_ taskId: UUID, for date: Date) -> Bool {
        return tasksCompleted.contains { $0.id == taskId && Calendar.current.isDate($0.dueDate, inSameDayAs: date) }
    }
    
    func markTaskAsCompleted(_ task: Task, on date: Date) {
        let taskComplete = TasksCompleted(id: task.id, dueDate: date)
        tasksCompleted.append(taskComplete)
        completedTaskIds.insert(task.id)
    }
    
    func unmarkTaskAsCompleted(_ task: Task, on date: Date) {
        tasksCompleted.removeAll { $0.id == task.id && Calendar.current.isDate($0.dueDate, inSameDayAs: date) }
        if !tasksCompleted.contains(where: { $0.id == task.id }) {
            completedTaskIds.remove(task.id)
        }
    }
    
    func toggleTaskCompletion(_ task: Task, on date: Date) {
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
}
