import SwiftUI
import CoreData
import Combine

class IdeaManager: ObservableObject {
    @Published var ideas: [Idea] = []

    private var context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
        fetchIdeas()
    }

    private func fetchIdeas() {
        let request: NSFetchRequest<Idea> = Idea.fetchRequest()

        do {
            ideas = try context.fetch(request)
        } catch {
            print("Ideaful: Error fetching ideas \(error)")
        }
    }
}
