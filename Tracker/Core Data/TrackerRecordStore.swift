//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Niykee Moore on 03.11.2024.
//

import Foundation
import CoreData

final class TrackerRecordStore: NSObject, NSFetchedResultsControllerDelegate {
    
    // MARK: - Properties
    
    var fetchedResultsController: NSFetchedResultsController<CDTrackerRecord>?
    var onRecordsUpdated: (() -> Void)?
    
    private let coreData = CoreDataManager.shared
    private let trackerStore = TrackerStore()
    private let managedObjectContext: NSManagedObjectContext
    
    // MARK: - Initialization
    
    init(managedObjectContext: NSManagedObjectContext = CoreDataManager.shared.persistentContainer.viewContext) {
        self.managedObjectContext = managedObjectContext
        super.init()
        setupFetchedResultsController()
    }
    
    // MARK: - Setup FetchedResultsControllerDelegate
    
    func setupFetchedResultsController(for trackerID: UUID? = nil, isCompleted: Bool? = nil) {
        let fetchRequest: NSFetchRequest<CDTrackerRecord> = CDTrackerRecord.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dueDate", ascending: true)]
        
        var predicates: [NSPredicate] = []
        
        if let trackerID = trackerID {
            predicates.append(NSPredicate(format: "tracker.id == %@", trackerID as CVarArg))
        }
        
        if let isCompleted = isCompleted {
            predicates.append(NSPredicate(format: "isCompleted == %@", NSNumber(value: isCompleted)))
        }
        
        if !predicates.isEmpty {
            fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: managedObjectContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        fetchedResultsController?.delegate = self
        
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            print("Ошибка performFetch: \(error)")
        }
    }
    
    // MARK: - Public Helper Methods
    
    func addRecordForTracker(for tracker: Tracker, on date: Date) {
        guard let cdTracker = trackerStore.convertToCDObject(from: tracker) else { return }
        
        let fetchRequest: NSFetchRequest<CDTrackerRecord> = CDTrackerRecord.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "tracker == %@ AND dueDate == %@", cdTracker, date as NSDate)
        
        if let existingRecord = try? coreData.context.fetch(fetchRequest), !existingRecord.isEmpty { return }
        
        let record = CDTrackerRecord(context: coreData.context)
        record.id = UUID()
        record.dueDate = date
        cdTracker.addToCompleted(record)
        
        coreData.saveContext()
    }
    
    func removeRecordForTracker(for tracker: Tracker, on date: Date) {
        guard let cdTracker = trackerStore.convertToCDObject(from: tracker) else { return }
        let fetchRequest: NSFetchRequest<CDTrackerRecord> = CDTrackerRecord.fetchRequest()
        
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)
        
        fetchRequest.predicate = NSPredicate(
            format: "tracker.id == %@ AND dueDate >= %@ AND dueDate < %@",
            tracker.id as CVarArg, startOfDay as NSDate, endOfDay! as NSDate
        )
        
        if let recordsToDelete = try? coreData.context.fetch(fetchRequest), let record = recordsToDelete.first {
            cdTracker.removeFromCompleted(record)
            coreData.context.delete(record)
            coreData.saveContext()
        }
    }
    
    func fetchAllRecords() -> [TrackerRecord] {
        let fetchRequest: NSFetchRequest<CDTrackerRecord> = CDTrackerRecord.fetchRequest()
        do {
            let trackerRecords = try coreData.context.fetch(fetchRequest)
            return trackerRecords.map {
                TrackerRecord(id: $0.tracker?.id ?? UUID(), dueDate: $0.dueDate ?? Date())
            }
        } catch {
            print("Ошибка при извлечении записей: \(error)")
            return []
        }
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        onRecordsUpdated?()
    }
}
