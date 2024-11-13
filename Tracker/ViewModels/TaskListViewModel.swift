//
//  TaskListViewModel.swift
//  Tracker
//
//  Created by Niykee Moore on 28.10.2024.
//

import UIKit

final class TaskListViewModel {
    
    // MARK: - Properties
    
    var selectedDay: Date = Date() {
        didSet {
            onSelectedDayChanged?()
        }
    }
    var onSelectedDayChanged: (() -> Void)?
    var onDataGetChanged: (() -> Void)?
    var onCompletedDaysCountUpdated: (() -> Void)?
    
    private var currentDate: Date {
        return Date()
    }
    private let trackerStore = TrackerStore()
    private let trackerRecordStore = TrackerRecordStore()
    private let trackerCategoryStore = TrackerCategoryStore()
    
    init() {
        trackerStore.onDataGetChanged = { [weak self] in
            self?.onDataGetChanged?()
        }
        
        trackerRecordStore.onRecordsUpdated = { [weak self] in
            self?.onCompletedDaysCountUpdated?()
        }
    }
    // MARK: - Public Helper Methods
    
    func fetchAllCategories() -> [TrackerCategory]?{
        return trackerCategoryStore.fetchAllCategories()
    }
    
    /*
     fixme:
     - Нерегулярная задача будет отображаться в день создания каждый день недели
     */
    func fetchTasksForDate(_ date: Date) -> [Tracker] {
        guard let weekDayToday = getDayOfWeek(from: date),
              let fetchedTasks = trackerStore.fetchAllTrackers(), !fetchedTasks.isEmpty else { return [] }
        
        return fetchedTasks.filter { task in
            task.schedule?.contains(weekDayToday) == true
        }
    }
    
    func hasTasksForToday(in section: Int) -> Bool {
        return fetchTasksForDate(currentDate).isEmpty == false
    }
    
    func isTaskCompleted(for task: Tracker, on date: Date) -> Bool {
        return trackerRecordStore.fetchAllRecords().contains {
            $0.id == task.id && Calendar.current.isDate($0.dueDate, inSameDayAs: date)
        }
    }
    
    func toggleCompletionStatus(_ task: Tracker, on date: Date) {
        if isTaskCompleted(for: task, on: date) {
            unmarkTaskAsCompleted(task, on: date)
        } else {
            markTaskAsCompleted(task, on: date)
        }
        onDataGetChanged?()
    }
    
    func completedDaysCount(for taskId: UUID) -> Int {
        return trackerRecordStore.fetchedResultsController?.fetchedObjects?.filter { $0.tracker?.id == taskId }.count ?? 0
    }
    
    func numberOfItems(in section: Int) -> Int {
        return fetchTasksForDate(selectedDay).count
    }
    
    func numberOfSections() -> Int {
        return trackerCategoryStore.fetchNumberOfCategories()
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
        trackerRecordStore.addRecordForTracker(for: task, on: date)
        onDataGetChanged?()
    }
    
    private func unmarkTaskAsCompleted(_ task: Tracker, on date: Date) {
        trackerRecordStore.removeRecordForTracker(for: task, on: date)
        onDataGetChanged?()
    }
}
