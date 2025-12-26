//
//  Tag+CoreDataProperties.swift
//  Ideaful
//
//  Created by Developer on 9/16/25.
//
//

public import Foundation
public import CoreData


public typealias TagCoreDataPropertiesSet = NSSet

extension Tag {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Tag> {
        return NSFetchRequest<Tag>(entityName: "Tag")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var color: String?
    @NSManaged public var ideas: NSSet?

}

// MARK: Generated accessors for ideas
extension Tag {

    @objc(addIdeasObject:)
    @NSManaged public func addToIdeas(_ value: Idea)

    @objc(removeIdeasObject:)
    @NSManaged public func removeFromIdeas(_ value: Idea)

    @objc(addIdeas:)
    @NSManaged public func addToIdeas(_ values: NSSet)

    @objc(removeIdeas:)
    @NSManaged public func removeFromIdeas(_ values: NSSet)

}

extension Tag : Identifiable {

}
