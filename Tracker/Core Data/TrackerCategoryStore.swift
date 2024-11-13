//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Niykee Moore on 03.11.2024.
//

import Foundation
import CoreData

final class TrackerCategoryStore: NSObject, NSFetchedResultsControllerDelegate {
    
    // MARK: - Properties
    
    var fetchedResultsController: NSFetchedResultsController<CDTrackerCategory>?
    
    private let coreData = CoreDataManager.shared
    private let managedObjectContext: NSManagedObjectContext
    
    // MARK: - Initialization
    
    init(managedObjectContext: NSManagedObjectContext = CoreDataManager.shared.persistentContainer.viewContext) {
        self.managedObjectContext = managedObjectContext
        super.init()
        setupFetchedResultsController()
    }
    
    // MARK: - Setup FetchedResultsControllerDelegate
    
    func setupFetchedResultsController() {
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
    
    func fetchOrCreateCategory(withTitle title: String) -> CDTrackerCategory? {
        let fetchRequest: NSFetchRequest<CDTrackerCategory> = CDTrackerCategory.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", title)
        
        do {
            let results = try coreData.context.fetch(fetchRequest)
            if let existingCategory = results.first {
                return existingCategory
            } else {
                let newCategory = CDTrackerCategory(context: coreData.context)
                newCategory.title = title
                return newCategory
            }
        } catch {
            print("Ошибка при получении или создании категории: \(error)")
            return nil
        }
    }
    
    func fetchNumberOfCategories() -> Int {
        return fetchedResultsController?.fetchedObjects?.count ?? 0
    }
    
    func fetchAllCategories() -> [TrackerCategory]? {
        let trackerStore = TrackerStore()
        guard let allFetchedTrackers = trackerStore.fetchAllTrackers() else { return [] }
        
        return fetchedResultsController?.fetchedObjects?.map { category in
            TrackerCategory(title: category.title ?? "",
                            tasks: allFetchedTrackers)
            
        } ?? []
    }
    
    func addTrackerToCategory(toCategory categoryTitle: String, tracker: CDTracker) {
        guard let category = fetchOrCreateCategory(withTitle: categoryTitle) else { return }
        category.addToTracker(tracker)
        coreData.saveContext()
    }
}
