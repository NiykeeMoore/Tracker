//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Niykee Moore on 03.11.2024.
//

import UIKit
import CoreData

final class TrackerCategoryStore: NSObject, NSFetchedResultsControllerDelegate {
    
    // MARK: - Properties
    
    private let coreData: CoreDataManager
    private var fetchedResultsController: NSFetchedResultsController<CDTrackerCategory>?
    private let managedObjectContext: NSManagedObjectContext
    
    // MARK: - Initialization
    
    init(coreData: CoreDataManager = CoreDataManager.shared,
         managedObjectContext: NSManagedObjectContext = CoreDataManager.shared.persistentContainer.viewContext) {
        self.coreData = coreData
        self.managedObjectContext = managedObjectContext
        super.init()
        setupFetchedResultsController()
    }
    
    // MARK: - Setup FetchedResultsControllerDelegate
    
    private func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<CDTrackerCategory> = CDTrackerCategory.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: managedObjectContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        fetchedResultsController?.delegate = self
        
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            print("Ошибка performFetch: \(error)")
        }
    }
    
    // MARK: - Public Helper Methods
    
    func fetchNumberOfCategories() -> Int {
        try? fetchedResultsController?.performFetch()
        return fetchedResultsController?.fetchedObjects?.count ?? 0
    }
    
    func fetchAllCategories() -> [TrackerCategory] {
        try? fetchedResultsController?.performFetch()
        guard let allFetchedCategories = fetchedResultsController?.fetchedObjects else { return [] }
        
        let allCategories = allFetchedCategories.map {
            TrackerCategory(title: $0.title ?? "", tasks: ($0.tracker?.allObjects as! [CDTracker]).map { cdTracker in
                Tracker(id: cdTracker.id ?? UUID(),
                        name: cdTracker.name ?? "",
                        color: UIColor(hex: cdTracker.color ?? "") ?? .clear,
                        emoji: cdTracker.emoji ?? "",
                        schedule: cdTracker.schedule as? [Weekdays] ?? [])
            })
        }
        
        return allCategories
    }
    
    func fetchCategoriesOnDate(date: Date) -> [TrackerCategory] {
        guard let dayOfWeek = getDayOfWeek(from: date) else { return [] }
        
        let allCategories = fetchAllCategories()
        
        let filteredCategories = allCategories.compactMap { category in
            let filteredTasks = category.tasks.filter { task in
                task.schedule?.contains(dayOfWeek) == true
            }
            return filteredTasks.isEmpty ? nil : TrackerCategory(title: category.title, tasks: filteredTasks)
        }
        return filteredCategories
    }
    
    func addTrackerToCategory(toCategory categoryTitle: String, tracker: Tracker) {
        guard let category = createOrFetchCategory(withTitle: categoryTitle) else { return }
        
        let convertedTracker = fetchCDTracker(by: tracker)
        convertedTracker.map { category.addToTracker($0) }
        
        coreData.saveContext()
    }
    
    func fetchAllCategoriesName() -> [String] {
        try? fetchedResultsController?.performFetch()
        return fetchAllCategories().map { $0.title }
    }
    
    func createCategory(name newCategory: String) {
        guard let _ = createOrFetchCategory(withTitle: newCategory) else { return }
    }
    
    // MARK: - Private Helper Methods
    
    private func createOrFetchCategory(withTitle title: String) -> CDTrackerCategory? {
        try? fetchedResultsController?.performFetch()
        if let categories = fetchedResultsController?.fetchedObjects,
           let existingCategory = categories.first(where: { $0.title == title }) {
            return existingCategory
        }
        
        let newCategory = CDTrackerCategory(context: coreData.context)
        newCategory.title = title
        coreData.saveContext()
        
        return newCategory
    }
    
    private func convertToCDObject(from tracker: Tracker) -> CDTracker {
        if let existingTracker = fetchCDTracker(by: tracker) {
            return existingTracker
        }
        
        let newConvertedTracker = CDTracker(context: coreData.context)
        newConvertedTracker.id = tracker.id
        newConvertedTracker.name = tracker.name
        newConvertedTracker.emoji = tracker.emoji
        newConvertedTracker.color = tracker.color.toHexString()
        newConvertedTracker.schedule = tracker.schedule as? NSObject
        return newConvertedTracker
    }
    
    private func fetchCDTracker(by tracker: Tracker) -> CDTracker? {
        let fetchRequest: NSFetchRequest<CDTracker> = CDTracker.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
        
        if let existingTracker = try? coreData.context.fetch(fetchRequest).first {
            return existingTracker
        }
        return nil
    }
    
    private func getDayOfWeek(from date: Date) -> Weekdays? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        dateFormatter.locale = Locale(identifier: "ru_RU")
        let dayString = dateFormatter.string(from: date).capitalized
        return Weekdays(rawValue: dayString)
    }
}
