import SwiftUI
import CoreData
import UserNotifications

struct TasksView: View {
    @Environment(\.managedObjectContext) var context
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var userSettings: UserSettings
    @FetchRequest private var tasks: FetchedResults<IdeaTask>
    
    @State private var newTaskTitle = ""
    @State private var selectedTask: IdeaTask?
    @State private var selectedFilter: TaskFilter = .all
    @State private var isHeaderCollapsed = false
    @State private var isAddingNewTask = false
    @State private var showingDeleteAlert = false
    
    let idea: Idea

    init(idea: Idea) {
        self.idea = idea
        _tasks = FetchRequest(
            entity: IdeaTask.entity(),
            sortDescriptors: [
                NSSortDescriptor(keyPath: \IdeaTask.priorityLevel, ascending: false),
                NSSortDescriptor(keyPath: \IdeaTask.tasked, ascending: true)
            ],
            predicate: NSPredicate(format: "idea == %@", idea),
            animation: .default
        )
    }

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
                    uncompletedTasksSection
                    completedTasksSection
                }
                .listStyle(.inset)
                
                addTaskBar
            }
            .navigationBarTitle("Idea Tasks".localized, displayMode: .inline)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack(spacing: 10) {
                        HStack {
                            Button(action: {
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                Image("arrow-left")
                                    .resizable()
                                    .renderingMode(.template)
                                    .foregroundColor(Color.colorPrimary)
                                    .scaledToFit()
                                    .frame(width: 22, height: 22)
                                    
                            }
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 10) {
                        if userSettings.showTaskOverview || userSettings.showTaskPriorities {
                            Button(action: {
                                withAnimation {
                                    isHeaderCollapsed.toggle()
                                }
                            }) {
                                Image(isHeaderCollapsed ? "chevron-down" : "chevron-up")
                                    .resizable()
                                    .renderingMode(.template)
                                    .foregroundColor(Color.colorPrimary)
                                    .scaledToFit()
                                    .frame(width: 22, height: 22)
                                    
                            }
                        }

                        Button(action: {
                            showingDeleteAlert = true
                        }) {
                            Image("square-check-trash")
                                .resizable()
                                .renderingMode(.template)
                                .foregroundColor(Color.colorPrimary)
                                .scaledToFit()
                                .frame(width: 22, height: 22)
                                
                        }
                    }
                }
            }
            .alert(isPresented: $showingDeleteAlert) {
                Alert(
                    title: Text("Clear Completed Tasks"),
                    message: Text("Are you sure you want to delete all completed tasks?"),
                    primaryButton: .destructive(Text("Delete")) {
                        deleteCompletedTasks()
                    },
                    secondaryButton: .cancel()
                )
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
                        .foregroundColor(color)
                        .scaledToFit()
                        .frame(width: 14, height: 14)
                    Text(title)
                        .font(.system(size: 12))
                        .foregroundColor(Color.colorPrimary)
                    Spacer()
                    Text("\(count)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color.colorPrimary)
                }
                if let overdueCount = overdueCount, overdueCount > 0 {
                    Text("Overdue: \(overdueCount)")
                        .font(.caption2)
                        .foregroundColor(Color.colorRed)
                }
                if let thisWeekCount = thisWeekCount, thisWeekCount > 0 {
                    Text("This Week: \(thisWeekCount)")
                        .font(.caption2)
                        .foregroundColor(Color.colorPrimary)
                }
            }
            .padding(8)
            .background(selectedFilter == filter ? color.opacity(0.3) : color.opacity(0.1))
            .cornerRadius(8)
        }
        
    }
    private var uncompletedTasksSection: some View {
        Section(header: Text("Uncompleted".localized)) {
            ForEach(filteredTasks.filter { !$0.isCompleted }, id: \.objectID) { task in
                NavigationLink(destination: AddEditTaskView(idea: idea, task: task)) {
                    TaskRow(task: task, toggleCompleted: toggleCompleted)
                }
            }
            .onDelete { offsets in
                deleteTasks(offsets: offsets, isCompleted: false)
            }
        }
    }

    private var completedTasksSection: some View {
        Section(header: Text("Completed".localized)) {
            ForEach(filteredTasks.filter { $0.isCompleted }, id: \.objectID) { task in
                NavigationLink(destination: AddEditTaskView(idea: idea, task: task)) {
                    TaskRow(task: task, toggleCompleted: toggleCompleted)
                }
            }
            .onDelete { offsets in
                deleteTasks(offsets: offsets, isCompleted: true)
            }
        }
    }

    private var addTaskBar: some View {
        HStack {
            TextField("New task...", text: $newTaskTitle, axis: .vertical)
                .padding()
                .glassEffect()

            if newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                NavigationLink(destination: AddEditTaskView(idea: idea, task: nil)) {
                    Image("plus")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(Color.colorPrimary)
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                }
                .padding()
                .background(Color.clear)
                .clipShape(Capsule())
                .glassEffect()
            } else {
                Button(action: addQuickTask) {
                    Image("plus")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(Color.colorPrimary)
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                }
                .padding()
                .background(Color.clear)
                .clipShape(Capsule())
                .glassEffect()
            }
        }
        .padding()
    }

    private func addQuickTask() {
        guard !newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }

        let task = IdeaTask(context: viewContext)
        task.tasked = newTaskTitle
        task.isCompleted = false
        task.idea = idea
        task.priorityLevel = 0  // Default priority level

        do {
            try viewContext.save()
            newTaskTitle = ""  // Clear the text field
            tasks.nsPredicate = tasks.nsPredicate  // Refresh fetch request
        } catch {
            print("Failed to save task: \(error)")
        }
    }

    
    private func toggleCompleted(task: IdeaTask) {
        task.isCompleted.toggle()
        
        do {
            try viewContext.save()
        } catch {
            print("Unable to change task completion status: \(error)")
        }
    }
    
    private func deleteTasks(offsets: IndexSet, isCompleted: Bool) {
        for index in offsets {
            let tasksList = tasks.filter { $0.isCompleted == isCompleted }
            let task = tasksList[index]
            viewContext.delete(task)
        }
        
        do {
            try viewContext.save()
        } catch {
            print("Failed to delete tasks: \(error)")
        }
    }
    
    private func deleteCompletedTasks() {
        let completedTasks = tasks.filter { $0.isCompleted }
        for task in completedTasks {
            viewContext.delete(task)
        }
        do {
            try viewContext.save()
        } catch {
            print("Failed to delete completed tasks: \(error)")
        }
    }
    
    // MARK: - Computed Properties
    
    private var tasksDueTodayCount: Int {
        tasks.filter { isDueToday(task: $0) && !$0.isCompleted }.count
    }
    
    private var overdueTasksCount: Int {
        tasks.filter { isOverdue(task: $0) && !$0.isCompleted }.count
    }
    
    private var tasksTomorrowCount: Int {
        tasks.filter { isTomorrow(task: $0) && !$0.isCompleted }.count
    }
    
    private var tasksThisWeekCount: Int {
        tasks.filter { isThisWeek(task: $0) && !$0.isCompleted }.count
    }
    
    private var highPriorityTasksCount: Int {
        tasks.filter { $0.priorityLevel == 3 && !$0.isCompleted }.count
    }
    
    private var mediumPriorityTasksCount: Int {
        tasks.filter { $0.priorityLevel == 2 && !$0.isCompleted }.count
    }
    
    private var lowPriorityTasksCount: Int {
        tasks.filter { $0.priorityLevel == 1 && !$0.isCompleted }.count
    }
    
    private var filteredTasks: [IdeaTask] {
        tasks.filter { task in
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
    
    // MARK: - Date Helper Functions
    
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
}

struct AddEditTaskView: View {
    @Environment(\.managedObjectContext) var viewContext
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var themeManager: ThemeManager

    let idea: Idea
    let task: IdeaTask?

    @State private var title: String
    @State private var description: String
    @State private var dueDate: Date
    @State private var priorityLevel: Int16
    @State private var reminder: Date

    @State private var showDueDate: Bool
    @State private var showReminder: Bool
    @State private var hasChanges: Bool = false

    init(idea: Idea, task: IdeaTask? = nil) {
        self.idea = idea
        self.task = task
        _title = State(initialValue: task?.tasked ?? "")
        _description = State(initialValue: task?.taskDesc ?? "")
        _dueDate = State(initialValue: task?.dueDate ?? Date())
        _priorityLevel = State(initialValue: task?.priorityLevel ?? 0)
        _reminder = State(initialValue: task?.reminder ?? Date())
        _showDueDate = State(initialValue: task?.dueDate != nil)
        _showReminder = State(initialValue: task?.reminder != nil)
    }

    var body: some View {
        VStack(spacing: 0) {
            List {
                Section {
                    VStack(alignment: .leading) {
                        Text("Title".localized)
                            .font(.system(size: 10))
                            .bold()
                        TextField("Enter title...", text: $title, axis: .vertical)
                            .lineLimit(2)
                            .onChange(of: title) { _ in
                                hasChanges = true
                            }
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Description".localized)
                            .font(.system(size: 10))
                            .bold()
                        TextField("Enter description...", text: $description, axis: .vertical)
                            .lineLimit(5)
                            .onChange(of: description) { _ in
                                hasChanges = true
                            }
                    }
                }

                Section {
                    VStack(alignment: .leading) {
                        Text("Priority".localized)
                            .font(.system(size: 10))
                            .bold()
                        Picker("", selection: $priorityLevel) {
                            Text("None").tag(Int16(0))
                            Text("Low").tag(Int16(1))
                            Text("Medium").tag(Int16(2))
                            Text("High").tag(Int16(3))
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .onChange(of: priorityLevel) { _ in
                            hasChanges = true
                        }
                    }
                }

                if showDueDate {
                    Section {
                        VStack(alignment: .leading) {
                            Text("Due Date".localized)
                                .font(.system(size: 10))
                                .bold()
                            DatePicker("", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                                .datePickerStyle(.compact)
                                .background(Color.clear.opacity(0.0))
                                .cornerRadius(20)
                                .glassEffect()
                                .labelsHidden()
                                .onChange(of: dueDate) { _ in
                                    hasChanges = true
                                }
                        }
                    }
                }

                if showReminder {
                    Section {
                        VStack(alignment: .leading) {
                            Text("Reminder".localized)
                                .font(.system(size: 10))
                                .bold()
                            DatePicker("", selection: $reminder, displayedComponents: [.date, .hourAndMinute])
                                .datePickerStyle(.compact)
                                .background(Color.clear.opacity(0.0))
                                .cornerRadius(20)
                                .glassEffect()
                                .labelsHidden()
                                .onChange(of: reminder) { _ in
                                    hasChanges = true
                                }
                        }
                    }
                }
            }.scrollDisabled(true)
            .listStyle(.inset)
        }
        .navigationBarTitle(task == nil ? "Add Task" : "Edit Task", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack {
                    Button(action: {
                        if hasChanges {
                            saveChanges()
                        }
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image("arrow-left")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(Color.colorPrimary)
                            .scaledToFit()
                            .frame(width: 22, height: 22)
                            
                    }
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 10) {
                    Button(action: {
                        showReminder.toggle()
                        if !showReminder {
                            reminder = Date()
                        }
                        hasChanges = true
                    }) {
                        Image(showReminder ? "clock-three" : "clock")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(showReminder ? Color.colorPrimary : .gray)
                            .frame(width: 22, height: 22)
                            
                    }

                    Button(action: {
                        showDueDate.toggle()
                        if !showDueDate {
                            dueDate = Date()
                        }
                        hasChanges = true
                    }) {
                        Image(showDueDate ? "calendar-alt" : "calendar")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(showDueDate ? Color.colorPrimary : .gray)
                            .frame(width: 22, height: 22)
                            
                    }

                    Button(action: {
                        priorityLevel = (priorityLevel + 1) % 4
                        hasChanges = true
                    }) {
                        Image("flag-fill")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(priorityColor)
                            .frame(width: 22, height: 22)
                            
                    }
                }
            }
        }
    }

    private var priorityColor: Color {
        switch priorityLevel {
        case 1: return Color.colorYellow
        case 2: return Color.colorOrange
        case 3: return Color.colorRed
        default: return .gray
        }
    }

    private func saveChanges() {
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }

        let taskToSave = task ?? IdeaTask(context: viewContext)
        taskToSave.tasked = title.trimmingCharacters(in: .whitespacesAndNewlines)
        taskToSave.taskDesc = description
        taskToSave.dueDate = showDueDate ? dueDate : nil
        taskToSave.priorityLevel = priorityLevel
        taskToSave.reminder = showReminder ? reminder : nil
        taskToSave.idea = idea
        taskToSave.isCompleted = task?.isCompleted ?? false

        do {
            try viewContext.save()
            if showReminder {
                scheduleNotification(for: reminder, title: title, subtitle: "Reminder", ideaTitle: idea.title ?? "")
            }
        } catch {
            print("Failed to save task: \(error)")
        }
    }

    private func scheduleNotification(for date: Date, title: String, subtitle: String, ideaTitle: String) {
        let content = UNMutableNotificationContent()
        content.title = "Ideaful"
        content.subtitle = "You have a task \(subtitle) for \(ideaTitle)"
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date), repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error.localizedDescription)")
            }
        }
    }
}

enum TaskFilter {
    case all, today, tomorrow, highPriority, mediumPriority, lowPriority
}

struct TaskRow: View {
    @ObservedObject var task: IdeaTask
    var toggleCompleted: (IdeaTask) -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(task.isCompleted ? "square-check" : "square")
                .resizable()
                .renderingMode(.template)
                .scaledToFit()
                .frame(width: 22, height: 22)
                .foregroundColor(task.isCompleted ? Color.colorGreen : (isOverdue(task: task) ? Color.colorRed : Color.colorGrey))
                .onTapGesture {
                    toggleCompleted(task)
                }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(task.tasked ?? "")
                    .font(.system(size: 16))
                    .fontWeight(.medium)
                
                if let description = task.taskDesc, !description.isEmpty {
                    Text(description)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                HStack(spacing: 8) {
                    if task.priorityLevel != 0 {
                        priorityLabel(for: task.priorityLevel)
                    }
                    if let dueDate = task.dueDate {
                        dueDateLabel(for: dueDate)
                    }
                    if let reminderDate = task.reminder {
                        reminderLabel(for: reminderDate)
                    }
                }
            }
            
            Spacer()
        }
        .contentShape(Rectangle())
    }

    private func priorityLabel(for level: Int16) -> some View {
        HStack(spacing: 4) {
            Image("flag-fill")
                .resizable()
                .renderingMode(.template)
                .foregroundColor(priorityColor(for: level))
                .frame(width: 12, height: 12)
            Text(priorityText(for: level))
                .font(.caption2)
                .foregroundColor(Color.colorPrimary)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(priorityColor(for: level).opacity(0.3))
        .cornerRadius(4)
    }

    private func dueDateLabel(for date: Date) -> some View {
        HStack(spacing: 4) {
            Image("calendar-alt")
                .resizable()
                .renderingMode(.template)
                .foregroundColor(Color.colorPrimary)
                .frame(width: 16, height: 16)
            Text(dateLabelFormatter.string(from: date))
                .font(.caption)
                .foregroundColor(Color.colorPrimary)
        }
    }

    private func reminderLabel(for date: Date) -> some View {
        HStack(spacing: 4) {
            Image("clock-three")
                .resizable()
                .renderingMode(.template)
                .foregroundColor(Color.colorPrimary)
                .frame(width: 16, height: 16)
            Text(dateLabelFormatter.string(from: date))
                .font(.caption)
                .foregroundColor(Color.colorPrimary)
        }
    }

    private func priorityText(for level: Int16) -> String {
        switch level {
        case 1: return "Low"
        case 2: return "Med"
        case 3: return "High"
        default: return ""
        }
    }

    private func priorityColor(for level: Int16) -> Color {
        switch level {
        case 1: return Color.colorYellow
        case 2: return Color.colorOrange
        case 3: return Color.colorRed
        default: return .gray
        }
    }
    
    private func isOverdue(task: IdeaTask) -> Bool {
        guard let dueDate = task.dueDate else { return false }
        return dueDate < Date()
    }
}

// MARK: - Helper Extensions

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
}()

private let dateLabelFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM d, yyyy"
    return formatter
}()

extension Binding where Value == Date? {
    init(_ source: Binding<Date?>, defaultValue: Date) {
        self.init(
            get: { source.wrappedValue ?? defaultValue },
            set: { newValue in source.wrappedValue = newValue }
        )
    }
}
