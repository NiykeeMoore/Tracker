//
//  CDTrackerRecord+CoreDataProperties.swift
//  Tracker
//
//  Created by Niykee Moore on 09.11.2024.
//
//

import Foundation
import CoreData


extension CDTrackerRecord {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDTrackerRecord> {
        return NSFetchRequest<CDTrackerRecord>(entityName: "CDTrackerRecord")
    }

    @NSManaged public var dueDate: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var tracker: CDTracker?

}

extension CDTrackerRecord : Identifiable {

}
