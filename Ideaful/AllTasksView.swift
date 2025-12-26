import SwiftUI
import CoreData

struct IdeaTaskGroup: Identifiable {
    let id = UUID()
    let title: String
    let tasks: [IdeaTask]
}

struct UncompletedTasksView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var userSettings: UserSettings

    @FetchRequest(
        entity: IdeaTask.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \IdeaTask.priorityLevel, ascending: false),
            NSSortDescriptor(keyPath: \IdeaTask.tasked, ascending: true)
        ],
        predicate: NSPredicate(format: "isCompleted == NO"),
        animation: .default
    ) private var uncompletedTasks: FetchedResults<IdeaTask>

    @State private var selectedFilter: TaskFilter = .all
    @State private var isHeaderCollapsed = false

    var body: some View {
        NavigationStack {
            VStack {
                if !isHeaderCollapsed {
                    VStack (spacing: 0) {
                        if userSettings.showTaskOverview {
                            taskOverviewRow
                        }
                        if userSettings.showTaskPriorities {
                            taskPrioritiesRow
                        }
                    }
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
                
                List {
                    if groupedTasks().isEmpty {
                        Text("No tasks match the current filter")
                            .foregroundColor(.gray)
                            .italic()
                            .padding()
                    } else {
                        ForEach(groupedTasks(), id: \.title) { group in
                            Section(header: ideaHeader(for: group.title)) {
                                ForEach(group.tasks, id: \.objectID) { task in
                                    NavigationLink(destination: AddEditTaskView(idea: task.idea ?? Idea(context: viewContext), task: task)) {
                                        TaskRow(task: task, toggleCompleted: toggleCompleted)
                                    }
                                }
                                .onDelete { offsets in
                                    deleteTasks(offsets: offsets, tasks: group.tasks)
                                }
                            }
                        }
                    }
                }
                .listStyle(.inset)
            }
            .navigationBarTitle("All Uncompleted Tasks", displayMode: .inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image("arrow-left")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(.colorPrimary)
                            .scaledToFit()
                            .frame(width: 22, height: 22)
                            
                            
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        if selectedFilter != .all {
                            Button(action: {
                                selectedFilter = .all
                            }) {
                                Image("filter-xmark")
                                    .resizable()
                                    .renderingMode(.template)
                                    .foregroundColor(.colorPrimary)
                                    .scaledToFit()
                                    .frame(width: 22, height: 22)
                                    
                            }
                        }
                        
                        Button(action: {
                            withAnimation {
                                isHeaderCollapsed.toggle()
                            }
                        }) {
                            Image(isHeaderCollapsed ? "chevron-down" : "chevron-up")
                                .resizable()
                                .renderingMode(.template)
                                .foregroundColor(.colorPrimary)
                                .scaledToFit()
                                .frame(width: 22, height: 22)
                                
                        }
                    }
                }
            }
        }
    }
    
    private var taskOverviewRow: some View {
        HStack(spacing: 16) {
            headerButton(title: "Today", icon: "calendar-alt", count: tasksDueTodayCount, overdueCount: overdueTasksCount, color: Color.colorPrimary, filter: .today)
            headerButton(title: "Tomorrow", icon: "clock", count: tasksTomorrowCount, thisWeekCount: tasksThisWeekCount, color: Color.colorPrimary, filter: .tomorrow)
        }
        .padding()
        .cornerRadius(8)
    }
    
    private var taskPrioritiesRow: some View {
        HStack(spacing: 16) {
            headerButton(title: "High", icon: "flag-fill", count: highPriorityTasksCount, color: Color.colorRed, filter: .highPriority)
            headerButton(title: "Med", icon: "flag-fill", count: mediumPriorityTasksCount, color: Color.colorOrange, filter: .mediumPriority)
            headerButton(title: "Low", icon: "flag-fill", count: lowPriorityTasksCount, color: Color.colorYellow, filter: .lowPriority)
        }
        .padding(.top, -15)
        .padding()
        .cornerRadius(8)
    }
    
    private func headerButton(title: String, icon: String, count: Int, overdueCount: Int? = nil, thisWeekCount: Int? = nil, color: Color, filter: TaskFilter) -> some View {
        Button(action: {
            selectedFilter = (selectedFilter == filter) ? .all : filter
        }) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(icon)
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(selectedFilter == filter ? .white : color)
                        .scaledToFit()
                        .frame(width: 14, height: 14)
                    Text(title)
                        .font(.system(size: 12))
                        .foregroundColor(selectedFilter == filter ? .white : Color.colorPrimary)
                    Spacer()
                    Text("\(count)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(selectedFilter == filter ? .white : Color.colorPrimary)
                }
                if let overdueCount = overdueCount, overdueCount > 0 {
                    Text("Overdue: \(overdueCount)")
                        .font(.caption2)
                        .foregroundColor(selectedFilter == filter ? .white : Color.colorRed)
                }
                if let thisWeekCount = thisWeekCount, thisWeekCount > 0 {
                    Text("This Week: \(thisWeekCount)")
                        .font(.caption2)
                        .foregroundColor(selectedFilter == filter ? .white : Color.colorPrimary)
                }
            }
            .padding(8)
            .background(selectedFilter == filter ? color : color.opacity(0.1))
            .cornerRadius(8)
        }
    }

    private func ideaHeader(for ideaTitle: String) -> some View {
        HStack {
            NavigationLink(destination: IdeaView(idea: uncompletedTasks.first(where: { $0.idea?.title == ideaTitle })?.idea ?? Idea(context: viewContext))) {
                Image("notebook")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(.colorPrimary)
                    .scaledToFit()
                    .frame(width: 18, height: 18)
                    
                
                Text(ideaTitle)
                    .font(.headline)
                    .foregroundColor(.colorPrimary)
            }
            .buttonStyle(BorderlessButtonStyle())


        }.padding(.leading, -5).padding(.horizontal, 12).padding(.vertical, 5).glassEffect()
    }

    // MARK: - Helper Methods

    private func groupedTasks() -> [IdeaTaskGroup] {
          let grouped = Dictionary(grouping: filteredTasks, by: { $0.idea?.title ?? "No Idea" })
          return grouped.map { IdeaTaskGroup(title: $0.key, tasks: $0.value) }.sorted(by: { $0.title < $1.title })
      }

    private func deleteTasks(offsets: IndexSet, tasks: [IdeaTask]) {
        for index in offsets {
            let task = tasks[index]
            viewContext.delete(task)
            task.idea?.tasksDeletedCount += 1
        }
        do {
            try viewContext.save()
            updateStats(viewContext: viewContext, tasksDeleted: offsets.count)
        } catch {
            print("Failed to delete tasks: \(error)")
        }
    }

    
    private var uncompletedTasksSection: some View {
        Section(header: Text("Uncompleted".localized)) {
            if filteredTasks.isEmpty {
                Text("No tasks match the current filter")
                    .foregroundColor(.gray)
                    .italic()
                    .padding()
            } else {
                ForEach(filteredTasks, id: \.objectID) { task in
                    NavigationLink(destination: AddEditTaskView(idea: task.idea ?? Idea(context: viewContext), task: task)) {
                        TaskRow(task: task, toggleCompleted: toggleCompleted)
                    }
                }
                .onDelete(perform: deleteTasks)
            }
        }
    }// MARK: - Helper Methods
    
    private func toggleCompleted(task: IdeaTask) {
        task.isCompleted.toggle()
        do {
            try viewContext.save()
            if task.isCompleted {
                updateStats(viewContext: viewContext, tasksCompleted: 1)
                task.idea?.tasksCompletedCount += 1
            } else {
                updateStats(viewContext: viewContext, tasksUncompleted: 1)
            }
        } catch {
            print("Ideaful: Unable to change task completion status \(error)")
        }
    }

    private func deleteTasks(at offsets: IndexSet) {
        for index in offsets {
            let task = filteredTasks[index]
            viewContext.delete(task)
            task.idea?.tasksDeletedCount += 1
        }
        do {
            try viewContext.save()
            updateStats(viewContext: viewContext, tasksDeleted: offsets.count)
        } catch {
            print("Failed to delete tasks: \(error)")
        }
    }

    // MARK: - Helper Functions

    private func isDueToday(task: IdeaTask) -> Bool {
        guard let dueDate = task.dueDate else { return false }
        return Calendar.current.isDateInToday(dueDate)
    }

    private func isTomorrow(task: IdeaTask) -> Bool {
        guard let dueDate = task.dueDate else { return false }
        return Calendar.current.isDateInTomorrow(dueDate)
    }

    private func isThisWeek(task: IdeaTask) -> Bool {
        guard let dueDate = task.dueDate else { return false }
        return Calendar.current.isDate(dueDate, equalTo: Date(), toGranularity: .weekOfYear)
    }

    private func isOverdue(task: IdeaTask) -> Bool {
        guard let dueDate = task.dueDate else { return false }
        return dueDate < Date()
    }

    // MARK: - Computed Properties

    private var filteredTasks: [IdeaTask] {
        uncompletedTasks.filter { task in
            switch selectedFilter {
            case .all:
                return true
            case .today:
                return isDueToday(task: task)
            case .tomorrow:
                return isTomorrow(task: task)
            case .highPriority:
                return task.priorityLevel == 3
            case .mediumPriority:
                return task.priorityLevel == 2
            case .lowPriority:
                return task.priorityLevel == 1
            }
        }
    }

    private var tasksDueTodayCount: Int {
        uncompletedTasks.filter { isDueToday(task: $0) }.count
    }

    private var tasksTomorrowCount: Int {
        uncompletedTasks.filter { isTomorrow(task: $0) }.count
    }

    private var tasksThisWeekCount: Int {
        uncompletedTasks.filter { isThisWeek(task: $0) }.count
    }

    private var highPriorityTasksCount: Int {
        uncompletedTasks.filter { $0.priorityLevel == 3 }.count
    }

    private var mediumPriorityTasksCount: Int {
        uncompletedTasks.filter { $0.priorityLevel == 2 }.count
    }

    private var lowPriorityTasksCount: Int {
        uncompletedTasks.filter { $0.priorityLevel == 1 }.count
    }

    private var overdueTasksCount: Int {
        uncompletedTasks.filter { isOverdue(task: $0) }.count
    }
}
