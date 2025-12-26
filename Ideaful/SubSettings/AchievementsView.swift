import SwiftUI
import CoreData

// MARK: - Model for Achievement (outside of CoreData)
struct AchievementModel {
    var achievementID: String
    var achievementTitle: String
    var achievementDesc: String
    var isUnlocked: Bool
}

// MARK: - Core Data Extension
extension Achievement {
    func toModel() -> AchievementModel {
        AchievementModel(
            achievementID: self.achievementID ?? UUID().uuidString, // Default to a random ID if nil
            achievementTitle: self.achievementTitle ?? "",
            achievementDesc: self.achievementDesc ?? "",
            isUnlocked: self.isUnlocked
        )
    }
    
    func update(from model: AchievementModel) {
        self.achievementID = model.achievementID
        self.achievementTitle = model.achievementTitle
        self.achievementDesc = model.achievementDesc
        //self.isUnlocked = model.isUnlocked
    }
}

// MARK: - Helper Functions
func addAchievements(to context: NSManagedObjectContext) {
    let achievements = [
        // Ideas Created
        AchievementModel(achievementID: "I01", achievementTitle: "First Idea", achievementDesc: "Created Your 1st Idea.", isUnlocked: false),
        AchievementModel(achievementID: "I02", achievementTitle: "Just The Start", achievementDesc: "Created Your 2nd Idea.", isUnlocked: false),
        AchievementModel(achievementID: "I03", achievementTitle: "Idea Expert", achievementDesc: "Created Your 10th Ideas.", isUnlocked: false),
        AchievementModel(achievementID: "I04", achievementTitle: "Vault of Ideas", achievementDesc: "Created Your 25th Ideas.", isUnlocked: false),
        // Ideas Completed
        AchievementModel(achievementID: "I05", achievementTitle: "Finished an Idea", achievementDesc: "Completed Your 1st Idea.", isUnlocked: false),
        AchievementModel(achievementID: "I06", achievementTitle: "Two For Two", achievementDesc: "Completed Your 2nd Idea.", isUnlocked: false),
        AchievementModel(achievementID: "I07", achievementTitle: "10 Out Of 10", achievementDesc: "Completed Your 10th Idea.", isUnlocked: false),
        AchievementModel(achievementID: "I08", achievementTitle: "Completionist", achievementDesc: "Completed Your 25th Idea.", isUnlocked: false),
        // Ideas Deleted
        AchievementModel(achievementID: "I09", achievementTitle: "Next Time", achievementDesc: "Delete Your 1st Idea.", isUnlocked: false),
        AchievementModel(achievementID: "I10", achievementTitle: "Bad Hand", achievementDesc: "Deleted Your 5th Idea.", isUnlocked: false),
        AchievementModel(achievementID: "I11", achievementTitle: "Wasn't Meant To Be", achievementDesc: "Deleted Your 10th Idea.", isUnlocked: false),
        AchievementModel(achievementID: "I12", achievementTitle: "CTRL ALT DELETE", achievementDesc: "Deleted Your 25th Idea.", isUnlocked: false),
        // Ideas Extra
        AchievementModel(achievementID: "I13", achievementTitle: "Plan Of Action", achievementDesc: "Start Planning An Idea.", isUnlocked: false),
        AchievementModel(achievementID: "I14", achievementTitle: "Developing It", achievementDesc: "Start Developing An Idea.", isUnlocked: false),
        AchievementModel(achievementID: "I15", achievementTitle: "Let's Put This On Hold", achievementDesc: "Put An Idea On Hold", isUnlocked: false),
        AchievementModel(achievementID: "I16", achievementTitle: "Uh-Oh Cancelled", achievementDesc: "Cancel An Idea", isUnlocked: false),
        AchievementModel(achievementID: "I17", achievementTitle: "Archived", achievementDesc: "Archive An Idea", isUnlocked: false),
        // Tasks Created
        AchievementModel(achievementID: "T01", achievementTitle: "First Task", achievementDesc: "Create your 1st task.", isUnlocked: false),
        AchievementModel(achievementID: "T02", achievementTitle: "Task Beginner", achievementDesc: "Create your 5th task.", isUnlocked: false),
        AchievementModel(achievementID: "T03", achievementTitle: "Task Expert", achievementDesc: "Create your 10th task.", isUnlocked: false),
        AchievementModel(achievementID: "T04", achievementTitle: "The Tasker", achievementDesc: "Create your 50th task.", isUnlocked: false),
        AchievementModel(achievementID: "T05", achievementTitle: "Tasked", achievementDesc: "Create your 100th task.", isUnlocked: false),
        AchievementModel(achievementID: "T06", achievementTitle: "Keeper of Tasks", achievementDesc: "Create your 250th task.", isUnlocked: false),
        AchievementModel(achievementID: "T07", achievementTitle: "Busy Life", achievementDesc: "Create your 500th task.", isUnlocked: false),
        AchievementModel(achievementID: "T08", achievementTitle: "Vault of Tasks", achievementDesc: "Create your 1000th task.", isUnlocked: false),
        // Tasks Completed
        AchievementModel(achievementID: "T09", achievementTitle: "Task Completed", achievementDesc: "Complete your 1st task.", isUnlocked: false),
        AchievementModel(achievementID: "T10", achievementTitle: "Tis To Easy", achievementDesc: "Complete your 5th task.", isUnlocked: false),
        AchievementModel(achievementID: "T11", achievementTitle: "Weekend Todo List", achievementDesc: "Completed your 10th task.", isUnlocked: false),
        AchievementModel(achievementID: "T12", achievementTitle: "Check", achievementDesc: "Completed your 50th task.", isUnlocked: false),
        AchievementModel(achievementID: "T13", achievementTitle: "Checkmate", achievementDesc: "Completed your 100th task.", isUnlocked: false),
        AchievementModel(achievementID: "T14", achievementTitle: "Task House", achievementDesc: "Completed your 250th task.", isUnlocked: false),
        AchievementModel(achievementID: "T15", achievementTitle: "Tis But A Task", achievementDesc: "Completed your 500th task.", isUnlocked: false),
        AchievementModel(achievementID: "T16", achievementTitle: "Can't Stop Me!", achievementDesc: "Completed your 1000th task.", isUnlocked: false),
        // Tasks Deleted
        AchievementModel(achievementID: "T17", achievementTitle: "Task Deleted", achievementDesc: "Deleted Your 1st task.", isUnlocked: false),
        AchievementModel(achievementID: "T18", achievementTitle: "Oops! There It Goes.", achievementDesc: "Deleted Your 5th task.", isUnlocked: false),
        AchievementModel(achievementID: "T19", achievementTitle: "Let's Do This...Nevermind.", achievementDesc: "Deleted Your 10th task.", isUnlocked: false),
        AchievementModel(achievementID: "T20", achievementTitle: "This Probably Didn't Need To Be.", achievementDesc: "Deleted Your 50th task.", isUnlocked: false),
        // Notes Created
        AchievementModel(achievementID: "N01", achievementTitle: "First Note", achievementDesc: "Create your 1st note.", isUnlocked: false),
        AchievementModel(achievementID: "N02", achievementTitle: "Note Beginner", achievementDesc: "Create your 5th note.", isUnlocked: false),
        AchievementModel(achievementID: "N03", achievementTitle: "Note Expert", achievementDesc: "Create your 10th note.", isUnlocked: false),
        AchievementModel(achievementID: "N04", achievementTitle: "The Notetaker", achievementDesc: "Create your 50th note.", isUnlocked: false),
        AchievementModel(achievementID: "N05", achievementTitle: "Noted", achievementDesc: "Create your 100th note.", isUnlocked: false),
        AchievementModel(achievementID: "N06", achievementTitle: "Keeper of Notes", achievementDesc: "Create your 250th note.", isUnlocked: false),
        AchievementModel(achievementID: "N07", achievementTitle: "Busy Notebook", achievementDesc: "Create your 500th note.", isUnlocked: false),
        AchievementModel(achievementID: "N08", achievementTitle: "Vault of Notes", achievementDesc: "Create your 1000th note.", isUnlocked: false),
        // Notes Deleted
        AchievementModel(achievementID: "N09", achievementTitle: "Note Deleted", achievementDesc: "Delete your 1st note.", isUnlocked: false),
        AchievementModel(achievementID: "N10", achievementTitle: "Oops! There It Goes.", achievementDesc: "Delete your 5th note.", isUnlocked: false),
        AchievementModel(achievementID: "N11", achievementTitle: "Let's Do This...Nevermind.", achievementDesc: "Delete your 10th note.", isUnlocked: false),
        AchievementModel(achievementID: "N12", achievementTitle: "This Probably Didn't Need To Be.", achievementDesc: "Delete your 50th note.", isUnlocked: false),
        AchievementModel(achievementID: "N13", achievementTitle: "Note Eliminator", achievementDesc: "Delete your 100th note.", isUnlocked: false),
        AchievementModel(achievementID: "N14", achievementTitle: "Note Purger", achievementDesc: "Delete your 250th note.", isUnlocked: false),
        AchievementModel(achievementID: "N15", achievementTitle: "Declutterer", achievementDesc: "Delete your 500th note.", isUnlocked: false),
        AchievementModel(achievementID: "N16", achievementTitle: "Vault Cleaner", achievementDesc: "Delete your 1000th note.", isUnlocked: false)
    ]
    
    for model in achievements {
        let fetchRequest: NSFetchRequest<Achievement> = Achievement.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "achievementID == %@", model.achievementID)
        
        do {
            let results = try context.fetch(fetchRequest)
            if results.count > 1 {
                // Remove duplicates
                for achievement in results.dropFirst() {
                    context.delete(achievement)
                }
            }
            
            if let existingAchievement = results.first {
                print("Updating existing achievement with ID: \(model.achievementID)")
                existingAchievement.update(from: model)
            } else {
                print("Creating a new achievement with ID: \(model.achievementID)")
                createAchievement(model, in: context)
            }
            try context.save()
        } catch {
            print("Failed to fetch or save achievement with ID: \(model.achievementID), error: \(error)")
        }
    }
}

func createAchievement(_ model: AchievementModel, in context: NSManagedObjectContext) {
    let newAchievement = Achievement(context: context)
    newAchievement.update(from: model)
}

struct AchievementsView: View {
    @Environment(\.managedObjectContext) var context
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var achievements: [Achievement] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    var totalAchievements: Int {
        achievements.count
    }

    var unlockedAchievements: Int {
        achievements.filter { $0.isUnlocked }.count
    }
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading achievements...")
            } else if let error = errorMessage {
                Text("Error: \(error)")
            } else {
                achievementsContent
            }
        }
        .navigationTitle("Achievements")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadAchievements()
        }
    }
    
    private var achievementsContent: some View {
        VStack(spacing: 0) {
            HStack {
                AchievementCountView(count: unlockedAchievements, label: "Unlocked", color: Color("colorGreen"), icon: "bookmark.fill")
                AchievementCountView(count: totalAchievements - unlockedAchievements, label: "Locked", color: .gray, icon: "bookmark")
            }
            .padding()
            
            List {
                ForEach(achievements, id: \.achievementID) { achievement in
                    AchievementRow(achievement: achievement)
                }
                .listRowBackground(Color.clear)
            }
            .listStyle(PlainListStyle())
            .scrollContentBackground(.hidden)
        }
    }
    
    private func loadAchievements() {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                addAchievements(to: context)
                
                let fetchRequest: NSFetchRequest<Achievement> = Achievement.fetchRequest()
                fetchRequest.sortDescriptors = [NSSortDescriptor(key: "achievementID", ascending: true)]
                
                let fetchedAchievements = try context.fetch(fetchRequest)
                
                DispatchQueue.main.async {
                    self.achievements = fetchedAchievements
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
}

struct AchievementCountView: View {
    let count: Int
    let label: String
    let color: Color
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
            Text("\(count) \(label)")
        }
        .font(.system(size: 14))
        .foregroundColor(.white)
        .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
        .background(color)
        .cornerRadius(8)
    }
}

struct AchievementRow: View {
    @EnvironmentObject var themeManager: ThemeManager
    let achievement: Achievement
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(achievement.achievementTitle ?? "")
                    .font(.headline)
                    
                Text(achievement.achievementDesc ?? "")
                    .font(.subheadline)
                    
            }
            Spacer()
            Image(systemName: achievement.isUnlocked ? "bookmark.fill" : "bookmark")
        }
        .padding(.vertical, 8)
    }
}
