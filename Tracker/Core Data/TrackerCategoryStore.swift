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
    
    func fetchAllCategories() -> [TrackerCategory]? {
        guard let allFetchedTrackers = StoreManager.shared.trackerStore.fetchAllTrackers() else { return [] }
        
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
    
    // MARK: - Private Helper Methods
    
    private func fetchOrCreateCategory(withTitle title: String) -> CDTrackerCategory? {
        if let categories = fetchedResultsController?.fetchedObjects,
           let existingCategory = categories.first(where: { $0.title == title }) {
            return existingCategory
        }
        
        let newCategory = CDTrackerCategory(context: coreData.context)
        newCategory.title = title
        coreData.saveContext()
        
        return newCategory
    }
}
