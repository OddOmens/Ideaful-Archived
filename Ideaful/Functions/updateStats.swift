import SwiftUI
import CoreData

func updateStats(viewContext: NSManagedObjectContext,
    ideasCreated: Int = 0,
    ideasDeleted: Int = 0,
    ideasCompleted: Int = 0,
    ideasCancelled: Int = 0,
    tasksCreated: Int = 0,
    tasksDeleted: Int = 0,
    tasksCompleted: Int = 0,
    tasksUncompleted: Int = 0,
    notesCreated: Int = 0,
    notesDeleted: Int = 0) {

    // Fetch the existing stats object or create a new one if it doesn't exist
    let stats: Stats
    let fetchRequest: NSFetchRequest<Stats> = Stats.fetchRequest()
    
    do {
        let statsArray = try viewContext.fetch(fetchRequest)
        if let existingStats = statsArray.first {
            stats = existingStats
        } else {
            stats = Stats(context: viewContext)
        }
    } catch {
        print("Failed to fetch Stats: \(error)")
        return
    }

    // Update the stats
    stats.totalIdeasCreated += Int64(ideasCreated)
    stats.totalIdeasDeleted += Int64(ideasDeleted)
    stats.totalIdeasCompleted += Int64(ideasCompleted)
    stats.totalIdeasCancelled += Int64(ideasCancelled)
    stats.totalTasksCreated += Int64(tasksCreated)
    stats.totalTasksCompleted += Int64(tasksCompleted)
    stats.totalTasksUncompleted += Int64(tasksUncompleted)
    stats.totalTasksDeleted += Int64(tasksDeleted)
    stats.totalNotesCreated += Int64(notesCreated)
    stats.totalNotesDeleted += Int64(notesDeleted)

    // Save the changes
    do {
        try viewContext.save()
    } catch {
        print("Failed to save updated stats: \(error)")
    }
}
