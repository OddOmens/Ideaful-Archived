import SwiftUI
import CoreData

func updateInvalidStatuses(context: NSManagedObjectContext) {
    // Define the valid statuses without localization initially
    let validStatuses = Set([
        "Unassigned",
        "New Idea",
        "Ideation",
        "Not Started",
        "Started",
        "Researching",
        "Planning",
        "Developing",
        "Prototyping", //3.0.0
        "Testing",
        "Reviewing",
        "Deferred",
        "Blocked",
        "Maintenance",
        "Quality Control",
        "Awaiting Feedback",
        "Awaiting Resources",
        "Pre-Production",
        "Production",
        "Post-Production",
        "On Hold",
        "Marketing", //3.0.0
        "Released",
        "Sunsetting",
        "Completed",
        "Cancelled",
        "Abandoned", //3.0.0
        "Archived",
        "Funded", 
        "Seeking Funding",
        "Pitching",
        "Validated",
        "Under Review"
    ])
    
    // Create a dictionary mapping the localized status to the original status
    let localizedValidStatuses = Dictionary(uniqueKeysWithValues: validStatuses.map { (NSLocalizedString($0, comment: ""), $0) })

    let fetchRequest = NSFetchRequest<Idea>(entityName: "Idea")
    
    do {
        let ideas = try context.fetch(fetchRequest)
        
        // Loop through each idea
        for idea in ideas {
            // Check if the status is invalid
            if let status = idea.status, localizedValidStatuses[status] == nil {
                // Update the status to "Unassigned"
                idea.status = NSLocalizedString("Unassigned", comment: "")
            }
        }
        
        // Save the changes
        try context.save()
        
    } catch let error {
        print("Failed to fetch ideas: \(error)")
    }
}
