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
    
    var onDataGetChanged: (() -> Void)?
    
    private let coreData: CoreDataManager
    private var fetchedResultsController: NSFetchedResultsController<CDTracker>?
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
        
        let cdTracker = CDTracker(context: coreData.context)
        cdTracker.id = entity.id
        cdTracker.name = entity.name
        cdTracker.emoji = entity.emoji
        cdTracker.color = entity.color.toHexString()
        cdTracker.schedule = entity.schedule as? NSObject
        
        coreData.saveContext()
        StoreManager.shared.categoryStore.addTrackerToCategory(toCategory: category, tracker: entity)
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
    
    func fetchTrackersOnDate(on weekday: Weekdays) -> [Tracker]? {
        guard let fetchedObjects = fetchedResultsController?.fetchedObjects else { return nil }
        
        let trackersForDate = fetchedObjects.compactMap { cdTracker -> Tracker? in
            guard let schedule = cdTracker.schedule as? [Weekdays],
                  schedule.contains(weekday) else { return nil }
            
            return Tracker(
                id: cdTracker.id ?? UUID(),
                name: cdTracker.name ?? "",
                color: UIColor(hex: cdTracker.color ?? "") ?? .clear,
                emoji: cdTracker.emoji ?? "",
                schedule: schedule
            )
        }
        
        return trackersForDate
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        onDataGetChanged?()
    }
}
