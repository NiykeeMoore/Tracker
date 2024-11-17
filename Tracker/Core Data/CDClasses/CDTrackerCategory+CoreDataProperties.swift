//
//  CDTrackerCategory+CoreDataProperties.swift
//  Tracker
//
//  Created by Niykee Moore on 09.11.2024.
//
//

import Foundation
import CoreData


extension CDTrackerCategory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDTrackerCategory> {
        return NSFetchRequest<CDTrackerCategory>(entityName: "CDTrackerCategory")
    }

    @NSManaged public var title: String?
    @NSManaged public var tracker: NSSet?

}

// MARK: Generated accessors for tracker
extension CDTrackerCategory {

    @objc(addTrackerObject:)
    @NSManaged public func addToTracker(_ value: CDTracker)

    @objc(removeTrackerObject:)
    @NSManaged public func removeFromTracker(_ value: CDTracker)

    @objc(addTracker:)
    @NSManaged public func addToTracker(_ values: NSSet)

    @objc(removeTracker:)
    @NSManaged public func removeFromTracker(_ values: NSSet)

}

extension CDTrackerCategory : Identifiable {

}
