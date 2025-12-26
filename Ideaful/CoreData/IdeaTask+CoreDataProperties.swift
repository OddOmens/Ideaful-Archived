//
//  IdeaTask+CoreDataProperties.swift
//  Ideaful
//
//  Created by Developer on 6/17/24.
//
//

import Foundation
import CoreData


extension IdeaTask {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<IdeaTask> {
        return NSFetchRequest<IdeaTask>(entityName: "IdeaTask")
    }

    @NSManaged public var isCompleted: Bool
    @NSManaged public var taskDesc: String?
    @NSManaged public var tasked: String?
    @NSManaged public var dueDate: Date?
    @NSManaged public var priorityLevel: Int16
    @NSManaged public var reminder: Date?
    @NSManaged public var idea: Idea?

}

extension IdeaTask : Identifiable {

}
