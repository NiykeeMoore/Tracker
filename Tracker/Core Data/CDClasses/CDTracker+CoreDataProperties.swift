//
//  CDTracker+CoreDataProperties.swift
//  Tracker
//
//  Created by Niykee Moore on 09.11.2024.
//
//

import Foundation
import CoreData


extension CDTracker {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDTracker> {
        return NSFetchRequest<CDTracker>(entityName: "CDTracker")
    }

    @NSManaged public var color: String?
    @NSManaged public var emoji: String?
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var schedule: NSObject?
    @NSManaged public var category: CDTrackerCategory?
    @NSManaged public var completed: NSSet?

}

// MARK: Generated accessors for completed
extension CDTracker {

    @objc(addCompletedObject:)
    @NSManaged public func addToCompleted(_ value: CDTrackerRecord)

    @objc(removeCompletedObject:)
    @NSManaged public func removeFromCompleted(_ value: CDTrackerRecord)

    @objc(addCompleted:)
    @NSManaged public func addToCompleted(_ values: NSSet)

    @objc(removeCompleted:)
    @NSManaged public func removeFromCompleted(_ values: NSSet)

}

extension CDTracker : Identifiable {

}
