import SwiftUI
import CoreData

public func checkAndUnlockAchievements(context: NSManagedObjectContext) {
    let fetchRequest: NSFetchRequest<Stats> = Stats.fetchRequest()
    if let statsArray = try? context.fetch(fetchRequest), let stats = statsArray.first {
        // Idea Achievement Check
        if stats.totalIdeasCreated >= 1 {
            unlockAchievement(withId: "I01", in: context)
        }
        if stats.totalIdeasCreated >= 2 {
            unlockAchievement(withId: "I02", in: context)
        }
        if stats.totalIdeasCreated >= 10 {
            unlockAchievement(withId: "I03", in: context)
        }
        if stats.totalIdeasCreated >= 25 {
            unlockAchievement(withId: "I04", in: context)
        }
        if stats.totalIdeasCompleted >= 1 {
            unlockAchievement(withId: "I05", in: context)
        }
        if stats.totalIdeasCompleted >= 2 {
            unlockAchievement(withId: "I06", in: context)
        }
        if stats.totalIdeasCompleted >= 10 {
            unlockAchievement(withId: "I07", in: context)
        }
        if stats.totalIdeasCompleted >= 25 {
            unlockAchievement(withId: "I08", in: context)
        }
        if stats.totalIdeasDeleted >= 1 {
            unlockAchievement(withId: "I09", in: context)
        }
        if stats.totalIdeasDeleted >= 2 {
            unlockAchievement(withId: "I10", in: context)
        }
        if stats.totalIdeasDeleted >= 10 {
            unlockAchievement(withId: "I11", in: context)
        }
        if stats.totalIdeasDeleted >= 25 {
            unlockAchievement(withId: "I12", in: context)
        }
        
        // Check for ideas with different statuses
        let statuses = ["New Idea", "Planning", "In Development", "On Hold", "Completed", "Cancelled", "Archived"]
        for status in statuses {
            let ideaFetchRequest: NSFetchRequest<Idea> = Idea.fetchRequest()
            ideaFetchRequest.predicate = NSPredicate(format: "status == %@", status)
            if let ideasWithStatus = try? context.fetch(ideaFetchRequest) {
                switch status {
                case "Planning":
                    if ideasWithStatus.count >= 1 {
                        unlockAchievement(withId: "I13", in: context)
                    }
                case "Development":
                    if ideasWithStatus.count >= 1 {
                        unlockAchievement(withId: "I14", in: context)
                    }
                case "On Hold":
                    if ideasWithStatus.count >= 1 {
                        unlockAchievement(withId: "I15", in: context)
                    }
                case "Cancelled":
                    if ideasWithStatus.count >= 1 {
                        unlockAchievement(withId: "I16", in: context)
                    }
                case "Archived":
                    if ideasWithStatus.count >= 1 {
                        unlockAchievement(withId: "I17", in: context)
                    }
                default:
                    break
                }
            }
        }
        
        // Task Achievement Check
        if stats.totalTasksCreated >= 1 {
            unlockAchievement(withId: "T01", in: context)
        }
        if stats.totalTasksCreated >= 5 {
            unlockAchievement(withId: "T02", in: context)
        }
        if stats.totalTasksCreated >= 10 {
            unlockAchievement(withId: "T03", in: context)
        }
        if stats.totalTasksCreated >= 50 {
            unlockAchievement(withId: "T04", in: context)
        }
        if stats.totalTasksCreated >= 100 {
            unlockAchievement(withId: "T05", in: context)
        }
        if stats.totalTasksCreated >= 250 {
            unlockAchievement(withId: "T06", in: context)
        }
        if stats.totalTasksCreated >= 500 {
            unlockAchievement(withId: "T07", in: context)
        }
        if stats.totalTasksCreated >= 1000 {
            unlockAchievement(withId: "T08", in: context)
        }
        if stats.totalTasksCompleted >= 1 {
            unlockAchievement(withId: "T09", in: context)
        }
        if stats.totalTasksCompleted >= 5 {
            unlockAchievement(withId: "T10", in: context)
        }
        if stats.totalTasksCompleted >= 10 {
            unlockAchievement(withId: "T11", in: context)
        }
        if stats.totalTasksCompleted >= 50 {
            unlockAchievement(withId: "T12", in: context)
        }
        if stats.totalTasksCompleted >= 100 {
            unlockAchievement(withId: "T13", in: context)
        }
        if stats.totalTasksCompleted >= 250 {
            unlockAchievement(withId: "T14", in: context)
        }
        if stats.totalTasksCompleted >= 500 {
            unlockAchievement(withId: "T15", in: context)
        }
        if stats.totalTasksCompleted >= 1000 {
            unlockAchievement(withId: "T16", in: context)
        }
        // Note Achievement Check
        if stats.totalNotesCreated >= 1 {
            unlockAchievement(withId: "N01", in: context)
        }
        if stats.totalNotesCreated >= 5 {
            unlockAchievement(withId: "N02", in: context)
        }
        if stats.totalNotesCreated >= 10 {
            unlockAchievement(withId: "N03", in: context)
        }
        if stats.totalNotesCreated >= 50 {
            unlockAchievement(withId: "N04", in: context)
        }
        if stats.totalNotesCreated >= 100 {
            unlockAchievement(withId: "N05", in: context)
        }
        if stats.totalNotesCreated >= 250 {
            unlockAchievement(withId: "N06", in: context)
        }
        if stats.totalNotesCreated >= 500 {
            unlockAchievement(withId: "N07", in: context)
        }
        if stats.totalNotesCreated >= 1000 {
            unlockAchievement(withId: "N08", in: context)
        }
        if stats.totalNotesDeleted >= 1 {
            unlockAchievement(withId: "N09", in: context)
        }
        if stats.totalNotesDeleted >= 5 {
            unlockAchievement(withId: "N10", in: context)
        }
        if stats.totalNotesDeleted >= 10 {
            unlockAchievement(withId: "N11", in: context)
        }
        if stats.totalNotesDeleted >= 50 {
            unlockAchievement(withId: "N12", in: context)
        }
        if stats.totalNotesDeleted >= 100 {
            unlockAchievement(withId: "N13", in: context)
        }
        if stats.totalNotesDeleted >= 250 {
            unlockAchievement(withId: "N14", in: context)
        }
        if stats.totalNotesDeleted >= 500 {
            unlockAchievement(withId: "N15", in: context)
        }
        if stats.totalNotesDeleted >= 1000 {
            unlockAchievement(withId: "N16", in: context)
        }
    }
}

public func unlockAchievement(withId id: String, in context: NSManagedObjectContext) {
    let fetchRequest: NSFetchRequest<Achievement> = Achievement.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "achievementID == %@", id)
    
    if let result = try? context.fetch(fetchRequest), let achievement = result.first, !achievement.isUnlocked {
        achievement.isUnlocked = true
        try? context.save()
        
        // Show toast notification if achievements are enabled in user settings
        /* if UserSettings().showUserAchievements {
            let message = "You've earned \(achievement.achievementTitle ?? "an") achievement"
            ToastNotificationViewModel.shared.showNotification(message: message, icon: "PreviewAppIcon")
        }*/
    }
}
