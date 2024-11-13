//
//  TrackerStore.swift
//  Tracker
//
//  Created by Niykee Moore on 03.11.2024.
//

import CoreData
import UIKit

final class TrackerStore: NSObject, NSFetchedResultsControllerDelegate {
    
    // MARK: - Properties
    
    var fetchedResultsController: NSFetchedResultsController<CDTracker>?
    var onDataGetChanged: (() -> Void)?
    
    private let coreData = CoreDataManager.shared
    private let trackerCategoryStore = TrackerCategoryStore()
    private let managedObjectContext: NSManagedObjectContext
    
    // MARK: - Initialization
    
    init(managedObjectContext: NSManagedObjectContext = CoreDataManager.shared.persistentContainer.viewContext) {
        self.managedObjectContext = managedObjectContext
        super.init()
        setupFetchedResultsController()
    }
    
    // MARK: - Setup FetchedResultsControllerDelegate
    func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<CDTracker> = CDTracker.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
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
    
    func createTracker(entity: Tracker, category: String) {
        guard let cdCategory = trackerCategoryStore.fetchOrCreateCategory(withTitle: category) else {
            print("Не удалось получить или создать категорию")
            return
        }
        
        let cdTracker = CDTracker(context: coreData.context)
        cdTracker.id = entity.id
        cdTracker.name = entity.name
        cdTracker.emoji = entity.emoji
        cdTracker.color = entity.color.toHexString()
        cdTracker.schedule = entity.schedule as? NSObject
        
        cdCategory.addToTracker(cdTracker)
        
        coreData.saveContext()
    }
    
    func fetchAllTrackers() -> [Tracker]? {
        guard let fetchedObjects = fetchedResultsController?.fetchedObjects else { return nil }
        return fetchedObjects.map { tracker in
            Tracker(id: tracker.id ?? UUID(),
                    name: tracker.name ?? "",
                    color: UIColor(hex: tracker.color ?? "") ?? .clear,
                    emoji: tracker.emoji ?? "",
                    schedule: tracker.schedule as? [Weekdays] ?? [] )
        }
    }
    
    func convertToCDObject(from tracker: Tracker) -> CDTracker? {
        let fetchRequest: NSFetchRequest<CDTracker> = CDTracker.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
        
        if let existingTracker = try? coreData.context.fetch(fetchRequest).first {
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
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        onDataGetChanged?()
    }
}
