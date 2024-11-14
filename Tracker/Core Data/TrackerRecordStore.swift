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
    
    var onRecordsUpdated: (() -> Void)?
    
    private let coreData = CoreDataManager.shared
    private var fetchedResultsController: NSFetchedResultsController<CDTrackerRecord>?
    private let trackerStore = TrackerStore()
    private let managedObjectContext: NSManagedObjectContext
    
    // MARK: - Initialization
    
    init(managedObjectContext: NSManagedObjectContext = CoreDataManager.shared.persistentContainer.viewContext) {
        self.managedObjectContext = managedObjectContext
        super.init()
        setupFetchedResultsController()
    }
    
    // MARK: - Setup FetchedResultsControllerDelegate
    
    private func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<CDTrackerRecord> = CDTrackerRecord.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        
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
        guard let cdTracker = convertToCDObject(from: tracker) else {
            print("Ошибка: не удалось конвертировать трекер в CD объект")
            return
        }
        
        let record = CDTrackerRecord(context: coreData.context)
        record.id = UUID()
        record.dueDate = date
        cdTracker.addToCompleted(record)
        
        coreData.saveContext()
    }
    
    func removeRecordForTracker(for tracker: Tracker, on date: Date) {
        guard let cdTracker = convertToCDObject(from: tracker) else { return }
        guard let fetchedRecords = fetchedResultsController?.fetchedObjects else { return }
        
        let filteredRecords = fetchedRecords.filter {
            $0.tracker?.id == tracker.id && $0.dueDate?.onlyDate == date.onlyDate
        }
        
        filteredRecords.forEach { record in
            cdTracker.removeFromCompleted(record)
            coreData.context.delete(record)
        }
        
        coreData.saveContext()
    }
    
    func fetchAllRecords() -> [TrackerRecord] {
        let fetchRequest: NSFetchRequest<CDTrackerRecord> = CDTrackerRecord.fetchRequest()
        do {
            let trackerRecords = try coreData.context.fetch(fetchRequest)
            return trackerRecords.map {
                TrackerRecord(id: $0.id ?? UUID(), dueDate: $0.dueDate ?? Date())
            }
        } catch {
            print("Ошибка при извлечении записей: \(error)")
            return []
        }
    }
    
    func isTaskComplete(for tracker: Tracker, on date: Date) -> Bool {
        guard let fetchedRecords = fetchedResultsController?.fetchedObjects else { return false }
        
        return fetchedRecords.contains { task in
            guard let taskDate = task.dueDate?.onlyDate else { return false }
            return task.tracker?.id == tracker.id && Calendar.current.isDate(taskDate, inSameDayAs: date.onlyDate)
        }
    }
    
    func countCompletedDays(for taskId: UUID) -> Int {
        return fetchedResultsController?.fetchedObjects?.filter { $0.tracker?.id == taskId }.count ?? 0
    }
    
    // MARK: - Private Helper Methods
    
    private func convertToCDObject(from tracker: Tracker) -> CDTracker? {
        
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
        onRecordsUpdated?()
    }
}
