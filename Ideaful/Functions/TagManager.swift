import Foundation
import CoreData
import SwiftUI

public class TagManager: ObservableObject {
    @Published var allTags: [Tag] = []
    
    private let viewContext: NSManagedObjectContext
    
    public init(context: NSManagedObjectContext) {
        self.viewContext = context
        loadTags()
    }
    
    public func loadTags() {
        let request: NSFetchRequest<Tag> = Tag.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Tag.name, ascending: true)]
        
        do {
            allTags = try viewContext.fetch(request)
        } catch {
            print("Error loading tags: \(error)")
            allTags = []
        }
    }
    
    public func createTag(name: String, color: String = "colorPrimary") -> Tag? {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return nil
        }
        
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if tagExists(name: trimmedName) {
            return nil
        }
        
        let tag = Tag(context: viewContext)
        tag.id = UUID()
        tag.name = trimmedName
        tag.color = color
        tag.createDate = Date()
        
        do {
            try viewContext.save()
            loadTags()
            return tag
        } catch {
            print("Error creating tag: \(error)")
            viewContext.rollback()
            return nil
        }
    }
    
    public func deleteTag(_ tag: Tag) {
        viewContext.delete(tag)
        
        do {
            try viewContext.save()
            loadTags()
        } catch {
            print("Error deleting tag: \(error)")
            viewContext.rollback()
        }
    }
    
    public func updateTag(_ tag: Tag, name: String?, color: String?) {
        if let name = name, !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
            if !tagExists(name: trimmedName) || tag.displayName == trimmedName {
                tag.name = trimmedName
            }
        }
        
        if let color = color {
            tag.color = color
        }
        
        do {
            try viewContext.save()
            loadTags()
        } catch {
            print("Error updating tag: \(error)")
            viewContext.rollback()
        }
    }
    
    func tagExists(name: String) -> Bool {
        let request: NSFetchRequest<Tag> = Tag.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", name)
        request.fetchLimit = 1
        
        do {
            let count = try viewContext.count(for: request)
            return count > 0
        } catch {
            print("Error checking if tag exists: \(error)")
            return false
        }
    }
    
    func getTags(for idea: Idea) -> [Tag] {
        return idea.tagsArray
    }
    
    func getIdeas(for tag: Tag) -> [Idea] {
        return tag.sortedIdeas
    }
    
    public func getAvailableColors() -> [(String, Color)] {
        return [
            ("colorPrimary", Color.colorPrimary),
            ("colorBlue", Color.colorBlue),
            ("colorGreen", Color.colorGreen),
            ("colorRed", Color.colorRed),
            ("colorOrange", Color.colorOrange),
            ("colorPurple", Color.colorPurple),
            ("colorYellow", Color.colorYellow),
            ("colorTeal", Color.colorTeal),
            ("colorMagenta", Color.colorMagenta),
            ("colorGrey", Color.colorGrey)
        ]
    }
}