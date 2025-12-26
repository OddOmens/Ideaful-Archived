import CoreData
import os
import UIKit

class PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentCloudKitContainer
    private let logger = Logger(subsystem: "com.yourapp.Ideaful", category: "PersistenceController")

    init(inMemory: Bool = false, useCloudKit: Bool = true) {
        container = NSPersistentCloudKitContainer(name: "Ideaful")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        let storeDescription = container.persistentStoreDescriptions.first

        if useCloudKit, let cloudKitContainerOptions = storeDescription?.cloudKitContainerOptions {
            #if DEBUG
            do {
                try container.initializeCloudKitSchema(options: [])
            } catch {
                logger.error("Failed to initialize CloudKit schema: \(error.localizedDescription)")
            }
            #endif
        }

        storeDescription?.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        storeDescription?.setOption(true as NSNumber, forKey: NSMigratePersistentStoresAutomaticallyOption)

        container.loadPersistentStores { [weak self] storeDescription, error in
            if let error = error as NSError? {
                self?.logger.error("Unresolved error loading persistent stores: \(error.localizedDescription)")
                // Here you might want to present an error to the user or attempt recovery
            } else {
                self?.performMigrationIfNeeded()
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    private func performMigrationIfNeeded() {
        let migrationKey = "LastMigrationVersion"
        let lastMigrationVersion = UserDefaults.standard.integer(forKey: migrationKey)
        let currentVersion = 2 // Increment this when adding new migrations

        if lastMigrationVersion < currentVersion {
            Task {
                if lastMigrationVersion < 1 {
                    await MigrationHelper.migrateOldNotes(context: container.viewContext)
                }
                if lastMigrationVersion < 2 {
                    await MigrationHelper.migrateImagePathsToData(context: container.viewContext)
                }
                UserDefaults.standard.set(currentVersion, forKey: migrationKey)
            }
        }
    }
}

class MigrationHelper {
    private static let logger = Logger(subsystem: "com.OddOmens.Ideaful", category: "MigrationHelper")

    static func migrateOldNotes(context: NSManagedObjectContext) async {
        let fetchRequest: NSFetchRequest<Idea> = Idea.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "notes != nil")

        do {
            let ideas = try context.fetch(fetchRequest)
            let total = ideas.count
            for (index, idea) in ideas.enumerated() {
                if let oldNoteText = idea.notes {
                    let newNote = Note(context: context)
                    newNote.title = "Migrated Notes"
                    newNote.text = oldNoteText
                    newNote.idea = idea
                    idea.notes = nil
                }
                if index % 100 == 0 {
                    try await context.perform {
                        try context.save()
                    }
                    logger.info("Migration progress: \(index)/\(total)")
                }
            }
            try await context.perform {
                try context.save()
            }
            logger.info("Migration completed successfully")
        } catch {
            logger.error("Migration failed: \(error.localizedDescription)")
        }
    }
    
    static func migrateImagePathsToData(context: NSManagedObjectContext) async {
        let fetchRequest: NSFetchRequest<Idea> = Idea.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "imagePaths != nil")

        do {
            let ideas = try context.fetch(fetchRequest)
            let total = ideas.count
            logger.info("Starting image migration for \(total) ideas")
            
            for (index, idea) in ideas.enumerated() {
                if let imagePathsString = idea.imagePaths, !imagePathsString.isEmpty {
                    let imagePaths = imagePathsString.components(separatedBy: ",")
                    var imageDataArray: [Data] = []
                    
                    for imagePath in imagePaths {
                        if let imageData = MigrationHelper.loadImageDataFromDocumentsDirectory(filename: imagePath.trimmingCharacters(in: .whitespacesAndNewlines)) {
                            imageDataArray.append(imageData)
                        }
                    }
                    
                    // Migration logic - keeping imagePaths as-is since we don't have imagesData
                    // The images will be loaded from file paths when needed
                    // NOT clearing imagePaths since we're using them for image storage
                }
                
                if index % 100 == 0 {
                    try await context.perform {
                        try context.save()
                    }
                    logger.info("Image migration progress: \(index)/\(total)")
                }
            }
            
            try await context.perform {
                try context.save()
            }
            logger.info("Image migration completed successfully")
        } catch {
            logger.error("Image migration failed: \(error.localizedDescription)")
        }
    }
    
    private static func loadImageDataFromDocumentsDirectory(filename: String) -> Data? {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsDirectory.appendingPathComponent(filename)
        
        do {
            return try Data(contentsOf: fileURL)
        } catch {
            logger.error("Failed to load image data from \(filename): \(error.localizedDescription)")
            return nil
        }
    }
}
