//
//  Stats+CoreDataProperties.swift
//  Ideaful
//
//  Created by Developer on 6/15/24.
//
//

import Foundation
import CoreData


extension Stats {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Stats> {
        return NSFetchRequest<Stats>(entityName: "Stats")
    }

    @NSManaged public var totalIdeasCancelled: Int64
    @NSManaged public var totalIdeasCompleted: Int64
    @NSManaged public var totalIdeasCreated: Int64
    @NSManaged public var totalIdeasDeleted: Int64
    @NSManaged public var totalTasksCompleted: Int64
    @NSManaged public var totalTasksCreated: Int64
    @NSManaged public var totalTasksDeleted: Int64
    @NSManaged public var totalTasksUncompleted: Int64
    @NSManaged public var totalNotesCreated: Int64
    @NSManaged public var totalNotesDeleted: Int64

}

extension Stats : Identifiable {

}
