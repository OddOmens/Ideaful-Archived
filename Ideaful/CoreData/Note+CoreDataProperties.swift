//
//  Note+CoreDataProperties.swift
//  Ideaful
//
//  Created by Developer on 6/8/24.
//
//

import Foundation
import CoreData


extension Note {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Note> {
        return NSFetchRequest<Note>(entityName: "Note")
    }

    @NSManaged public var text: String?
    @NSManaged public var timeStamp: Date?
    @NSManaged public var title: String?
    @NSManaged public var idea: Idea?

}

extension Note : Identifiable {

}
