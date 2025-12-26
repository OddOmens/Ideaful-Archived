//
//  Achievement+CoreDataProperties.swift
//  Ideaful
//
//  Created by Developer on 9/2/23.
//
//

import Foundation
import CoreData


extension Achievement {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Achievement> {
        return NSFetchRequest<Achievement>(entityName: "Achievement")
    }

    @NSManaged public var achievementDesc: String?
    @NSManaged public var achievementID: String?
    @NSManaged public var achievementTitle: String?
    @NSManaged public var isUnlocked: Bool

}

extension Achievement : Identifiable {

}
