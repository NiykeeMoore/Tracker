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
    private let trackerStore = StoreManager.shared.trackerStore
    private let trackerRecordStore = StoreManager.shared.recordStore
    private let trackerCategoryStore = StoreManager.shared.categoryStore
    
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
    func fetchTasksForDate(_ date: Date) -> [TrackerCategory] {
        return trackerCategoryStore.fetchCategoriesOnDate(date: date)
    }
    
    func hasTasksForToday() -> Bool {
        return fetchTasksForDate(selectedDay.onlyDate).isEmpty == false
    }
    
    func isTaskCompleted(for task: Tracker, on date: Date) -> Bool {
        return trackerRecordStore.isTaskComplete(for: task, on: date)
    }
    
    func toggleCompletionStatus(_ task: Tracker, on date: Date) {
        if isTaskCompleted(for: task, on: date) {
            unmarkTaskAsCompleted(task, on: date)
        } else {
            markTaskAsCompleted(task, on: date)
        }
    }
    
    func completedDaysCount(for taskId: UUID) -> Int {
        return trackerRecordStore.countCompletedDays(for: taskId)
    }
    
    func numberOfItems(in section: Int) -> Int {
        return fetchTasksForDate(selectedDay.onlyDate).count
    }
    
    func numberOfSections() -> Int {
        return fetchTasksForDate(selectedDay.onlyDate).count
    }
    
    // MARK: - Private Helper Methods
    
    private func markTaskAsCompleted(_ task: Tracker, on date: Date) {
        trackerRecordStore.addRecordForTracker(for: task, on: date)
    }
    
    private func unmarkTaskAsCompleted(_ task: Tracker, on date: Date) {
        trackerRecordStore.removeRecordForTracker(for: task, on: date)
    }
}
