//
//  Idea+CoreDataProperties.swift
//  Ideaful
//
//  Updated for Ideaful 5 model - Image sync fix
//
//

import Foundation
import CoreData


extension Idea {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Idea> {
        return NSFetchRequest<Idea>(entityName: "Idea")
    }

    @NSManaged public var createDate: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var note: String?
    @NSManaged public var notes: String?
    @NSManaged public var notesCreatedCount: Int64
    @NSManaged public var notesDeletedCount: Int64
    @NSManaged public var shortDesc: String?
    @NSManaged public var status: String?
    @NSManaged public var tasksCompletedCount: Int64
    @NSManaged public var tasksCreatedCount: Int64
    @NSManaged public var tasksDeletedCount: Int64
    @NSManaged public var title: String?
    @NSManaged public var updateDate: Date?
    @NSManaged public var imagePaths: String?
    @NSManaged public var ideaNotes: NSSet?
    @NSManaged public var tags: NSSet?
    @NSManaged public var tasks: NSSet?

}

// MARK: Generated accessors for ideaNotes
extension Idea {

    @objc(addIdeaNotesObject:)
    @NSManaged public func addToIdeaNotes(_ value: Note)

    @objc(removeIdeaNotesObject:)
    @NSManaged public func removeFromIdeaNotes(_ value: Note)

    @objc(addIdeaNotes:)
    @NSManaged public func addToIdeaNotes(_ values: NSSet)

    @objc(removeIdeaNotes:)
    @NSManaged public func removeFromIdeaNotes(_ values: NSSet)

}

// MARK: Generated accessors for tags
extension Idea {

    @objc(addTagsObject:)
    @NSManaged public func addToTags(_ value: Tag)

    @objc(removeTagsObject:)
    @NSManaged public func removeFromTags(_ value: Tag)

    @objc(addTags:)
    @NSManaged public func addToTags(_ values: NSSet)

    @objc(removeTags:)
    @NSManaged public func removeFromTags(_ values: NSSet)

}

// MARK: Generated accessors for tasks
extension Idea {

    @objc(addTasksObject:)
    @NSManaged public func addToTasks(_ value: IdeaTask)

    @objc(removeTasksObject:)
    @NSManaged public func removeFromTasks(_ value: IdeaTask)

    @objc(addTasks:)
    @NSManaged public func addToTasks(_ values: NSSet)

    @objc(removeTasks:)
    @NSManaged public func removeFromTasks(_ values: NSSet)

}

extension Idea : Identifiable {

}
