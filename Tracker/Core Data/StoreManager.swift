//
//  StoreManager.swift
//  Tracker
//
//  Created by Niykee Moore on 15.11.2024.
//

import Foundation

final class StoreManager {
    static let shared = StoreManager()
    
    let trackerStore: TrackerStore
    let categoryStore: TrackerCategoryStore
    let recordStore: TrackerRecordStore
    
    private init() {
        let context = CoreDataManager.shared.context
        self.trackerStore = TrackerStore(managedObjectContext: context)
        self.categoryStore = TrackerCategoryStore(managedObjectContext: context)
        self.recordStore = TrackerRecordStore(managedObjectContext: context)
    }
}
