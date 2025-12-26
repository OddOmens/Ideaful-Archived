import SwiftUI
import CoreData

struct DashboardView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.openURL) private var openURL
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var userSettings: UserSettings
    @EnvironmentObject var iconManager: IconManager
    @EnvironmentObject var statusManager: StatusManager

    @FetchRequest(
        entity: Idea.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Idea.title, ascending: true)]
    ) private var ideas: FetchedResults<Idea>

    @State private var refresh: Bool = false
    @State private var selectedIdea: Idea?
    @State private var expandedStatuses: [String: Bool] = [:]
    @State private var selectedTags: Set<Tag> = []
    @State private var showTagFilterBar: Bool = false
    
    @State private var showSettingView = false
    @State private var showSearchView = false
    @State private var showEditIdeaView = false
    @State private var showAllTasksView = false
    @State private var showAddIdeaView = false
    
    @State private var ideaToDelete: Idea?
    @State private var showDeleteConfirmation = false
    
    @State private var AddIdeaDetent = PresentationDetent.medium
    @State private var showNewTagSheet = false
    @State private var showTagsManagementSheet = false
    @State private var showBulkTagSheet = false
    @State private var selectedIdeasForBulkTag: Set<Idea> = []
    @State private var isSelectionMode = false
    @State private var bulkActionType: BulkActionType = .tag

    @ObservedObject private var languageManager = LanguageManager.shared

    enum BulkActionType {
        case tag
        case archive
    }
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background list that extends behind everything
                List {
                    ForEach(GlobalConstants.orderedStatuses, id: \.self) { statusName in
                        StatusSectionView(
                            statusName: statusName,
                            statusManager: statusManager,
                            ideas: ideas,
                            selectedTags: selectedTags,
                            expandedStatuses: $expandedStatuses,
                            userSettings: userSettings,
                            ideaToDelete: $ideaToDelete,
                            showDeleteConfirmation: $showDeleteConfirmation,
                            deleteIdea: deleteIdea,
                            changeIdeaStatus: changeIdeaStatus,
                            isSelectionMode: $isSelectionMode,
                            selectedIdeasForBulkTag: $selectedIdeasForBulkTag
                        )
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .ignoresSafeArea(.container, edges: .bottom)
                .id(refresh)
                //.animation(.smooth(duration: 0.28), value: showTagFilterBar) // Removed this line as per instructions
                .safeAreaInset(edge: .top) {
                    Color.clear.frame(height: showTagFilterBar ? 60 : 10)
                }
                .safeAreaInset(edge: .bottom) {
                    Color.clear.frame(height: 50)
                }
                .animation(.smooth(duration: 0.4, extraBounce: 0.0), value: showTagFilterBar)
                
                // Floating glass tag filter bar
                VStack (spacing: 10) {
                    if showTagFilterBar {
                        DashboardTagFilterBar(
                            selectedTags: $selectedTags,
                            showNewTagSheet: $showNewTagSheet
                        )
                        .padding(.vertical, 4)
                        .padding(.horizontal, 12)
                        .frame(maxWidth: .infinity)
                        .glassEffect()
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    Spacer()
                }.padding(.horizontal)
            }
            .animation(.smooth(duration: 0.4, extraBounce: 0.0), value: showTagFilterBar) // Enhanced smooth animation
            .navigationTitle("Ideas & Projects".localized)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbarBackground(.clear, for: .navigationBar)
            .toolbarBackgroundVisibility(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack (spacing:10) {
                        if isSelectionMode {
                            Button(action: {
                                isSelectionMode = false
                                selectedIdeasForBulkTag.removeAll()
                            }) {
                                Text("Cancel")
                                    .foregroundColor(Color.colorPrimary)
                            }
                        } else {
                            Menu {
                                // Management section
                                Section {
                                    NavigationLink {
                                        StatusesView()
                                    } label: {
                                        Label {
                                            Text("Statuses")
                                        } icon: {
                                            Image("flag")
                                                .resizable()
                                                .renderingMode(.template)
                                                .foregroundColor(Color.colorPrimary)
                                                .scaledToFit()
                                                .frame(width: 18, height: 18)
                                        }
                                    }

                                    Button(action: {
                                        showTagsManagementSheet = true
                                    }) {
                                        Label {
                                            Text("Tags")
                                        } icon: {
                                            Image("tag")
                                                .resizable()
                                                .renderingMode(.template)
                                                .foregroundColor(Color.colorPrimary)
                                                .scaledToFit()
                                                .frame(width: 18, height: 18)
                                        }
                                    }

                                    NavigationLink {
                                        CustomizeView()
                                    } label: {
                                        Label {
                                            Text("Features")
                                        } icon: {
                                            Image("stars")
                                                .resizable()
                                                .renderingMode(.template)
                                                .foregroundColor(Color.colorPrimary)
                                                .scaledToFit()
                                                .frame(width: 18, height: 18)
                                        }
                                    }
                            } header: {
                                Text("Manage")
                            }

                            // Bulk Actions section
                            Section {
                                Button(action: {
                                    isSelectionMode = true
                                    bulkActionType = .tag
                                }) {
                                    Label {
                                        Text("Bulk Tag Ideas")
                                    } icon: {
                                        Image("tag")
                                            .resizable()
                                            .renderingMode(.template)
                                            .foregroundColor(Color.colorPrimary)
                                            .scaledToFit()
                                            .frame(width: 18, height: 18)
                                    }
                                }

                                Button(action: {
                                    isSelectionMode = true
                                    bulkActionType = .archive
                                }) {
                                    Label {
                                        Text("Bulk Archive Ideas")
                                    } icon: {
                                        Image("box-archive")
                                            .resizable()
                                            .renderingMode(.template)
                                            .foregroundColor(Color.colorPrimary)
                                            .scaledToFit()
                                            .frame(width: 18, height: 18)
                                    }
                                }
                            } header: {
                                Text("Actions")
                            }
                            
                            // Support section
                            Section {
                                Link(destination: URL(string: "https://ko-fi.com/kadynmade")!) {
                                    Label {
                                        Text("Support Ideaful")
                                    } icon: {
                                        Image("trophy")
                                            .resizable()
                                            .renderingMode(.template)
                                            .foregroundColor(Color.colorPrimary)
                                            .scaledToFit()
                                            .frame(width: 18, height: 18)
                                    }
                                }
                                
                                Button(action: { 
                                    if let url = URL(string: "https://apps.apple.com/app/ideaful/id123456789") {
                                        openURL(url)
                                    }
                                }) {
                                    Label {
                                        Text("Rate Ideaful")
                                    } icon: {
                                        Image("star")
                                            .resizable()
                                            .renderingMode(.template)
                                            .foregroundColor(Color.colorPrimary)
                                            .scaledToFit()
                                            .frame(width: 18, height: 18)
                                    }
                                }
                            } header: {
                                Text("Support")
                            }
                            
                            // Settings section
                            Section {
                                NavigationLink {
                                    SettingsView()
                                } label: {
                                    Label {
                                        Text("Settings")
                                    } icon: {
                                        Image("gear")
                                            .resizable()
                                            .renderingMode(.template)
                                            .foregroundColor(Color.colorPrimary)
                                            .scaledToFit()
                                            .frame(width: 18, height: 18)
                                    }
                                }
                            }
                        } label: {
                            Image("menu")
                                .resizable()
                                .renderingMode(.template)
                                .foregroundColor(Color.colorPrimary)
                                .scaledToFit()
                                .frame(width: 22, height: 22)
                                
                            }.padding(.leading, 5)
                            Button(action: {
                                withAnimation(.smooth(duration: 0.4, extraBounce: 0.0)) {
                                    showTagFilterBar.toggle()
                                }
                            }) {
                                Image("tag")
                                    .resizable()
                                    .renderingMode(.template)
                                    .foregroundColor(Color.colorPrimary)
                                    .scaledToFit()
                                    .frame(width: 22, height: 22)
                            }.padding(.trailing, 5)
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack (spacing:10) {
                        if isSelectionMode {
                            Button(action: {
                                switch bulkActionType {
                                case .tag:
                                    showBulkTagSheet = true
                                case .archive:
                                    bulkArchiveIdeas()
                                }
                            }) {
                                Image(bulkActionType == .tag ? "tag" : "box-archive")
                                    .resizable()
                                    .renderingMode(.template)
                                    .foregroundColor(Color.colorPrimary)
                                    .scaledToFit()
                                    .frame(width: 22, height: 22)
                            }
                            .disabled(selectedIdeasForBulkTag.isEmpty)
                        } else {
                            if userSettings.showTasks {
                                NavigationLink(destination: UncompletedTasksView()) {
                                    Image("list")
                                        .resizable()
                                        .renderingMode(.template)
                                        .foregroundColor(Color.colorPrimary)
                                        .scaledToFit()
                                        .frame(width: 22, height: 22)

                                        .overlay(
                                            allTaskCountOverlay
                                        )
                                }
                            }

                            NavigationLink(destination: AddIdeaView()) {
                                Image("plus")
                                    .resizable()
                                    .renderingMode(.template)
                                    .foregroundColor(Color.colorPrimary)
                                    .scaledToFit()
                                    .frame(width: 22, height: 22)

                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            refreshList()
            print("Dashboard Triggered")
        }
        .onChange(of: languageManager.selectedLanguage) { _ in
            refreshList()
        }
        .alert(isPresented: $showDeleteConfirmation) {
            Alert(
                title: Text("Delete Idea"),
                message: Text("Are you sure you want to delete this idea?"),
                primaryButton: .destructive(Text("Delete")) {
                    if let ideaToDelete = ideaToDelete {
                        deleteIdea(ideaToDelete)
                    }
                },
                secondaryButton: .cancel()
            )
        }
        .sheet(isPresented: $showNewTagSheet) {
            DashboardNewTagSheetView()
                .presentationDetents([.medium])
        }
        .sheet(isPresented: $showTagsManagementSheet) {
            TagsManagementView()
                .presentationDetents([.medium])
        }
        .sheet(isPresented: $showBulkTagSheet) {
            BulkTagSelectorView(selectedIdeas: $selectedIdeasForBulkTag, isSelectionMode: $isSelectionMode)
                .presentationDetents([.medium])
        }
    }
    
    
    private var allTaskCountOverlay: some View {
        let uncompletedTasksCount = fetchUncompletedTasksCount(context: viewContext)

        return ZStack {
            if userSettings.showAllTaskCount && uncompletedTasksCount > 0 {
                Circle()
                    .fill(Color.colorGreen)
                    .frame(width: 14, height: 14)
                Text(uncompletedTasksCount > 99 ? "99" : "\(uncompletedTasksCount)")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .offset(x: 10, y: -8)
    }

    func fetchUncompletedTasksCount(context: NSManagedObjectContext) -> Int {
        let fetchRequest: NSFetchRequest<IdeaTask> = IdeaTask.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isCompleted == NO")
        
        do {
            let tasks = try context.fetch(fetchRequest)
            return tasks.count
        } catch {
            print("Failed to fetch uncompleted tasks: \(error)")
            return 0
        }
    }
    
    private func shouldShowIdea(_ idea: Idea) -> Bool {
        guard let status = idea.status else { return false }
        
        switch status {
        case "Cancelled":
            return userSettings.showCancelledIdeas
        case "Completed":
            return userSettings.showCompletedIdeas
        case "Archived":
            return userSettings.showArchivedIdeas
        default:
            return true
        }
    }

    private func refreshList() {
        refresh.toggle()
    }
    
    private func shouldShowIdea(_ idea: Idea, withStatus status: String) -> Bool {
        let showCancelledIdeas = userSettings.showCancelledIdeas
        let showCompletedIdeas = userSettings.showCompletedIdeas
        let showArchivedIdeas = userSettings.showArchivedIdeas
        
        // Check if the idea has a status, and match it with the given status
        guard let ideaStatus = idea.status else { return false }

        // Access the status directly from the orderedStatuses array
        let cancelledStatus = GlobalConstants.orderedStatuses.first { $0 == "Cancelled" }
        let completedStatus = GlobalConstants.orderedStatuses.first { $0 == "Completed" }
        let archivedStatus = GlobalConstants.orderedStatuses.first { $0 == "Archived" }

        // Hide cancelled ideas if the user doesn't want to show them
        if status == cancelledStatus && !showCancelledIdeas {
            return false
        }
        
        // Hide completed ideas if the user doesn't want to show them
        if status == completedStatus && !showCompletedIdeas {
            return false
        }
        
        // Hide archived ideas if the user doesn't want to show them
        if status == archivedStatus && !showArchivedIdeas {
            return false
        }

        // Show the idea if it passes all filters
        return true
    }
    
    private func deleteIdea(_ idea: Idea) {
        viewContext.delete(idea)
        do {
            try viewContext.save()
            refreshList()
        } catch {
            // Handle the error appropriately
            print("Error deleting idea: \(error)")
        }
    }
    
    private func changeIdeaStatus(_ idea: Idea, _ newStatus: String) {
        idea.status = newStatus
        idea.updateDate = Date()

        do {
            try viewContext.save()
            refreshList()
        } catch {
            print("Error updating idea status: \(error)")
        }
    }

    private func bulkArchiveIdeas() {
        for idea in selectedIdeasForBulkTag {
            idea.status = "Archived"
            idea.updateDate = Date()
        }

        do {
            try viewContext.save()
            selectedIdeasForBulkTag.removeAll()
            isSelectionMode = false
            refreshList()
        } catch {
            print("Error bulk archiving ideas: \(error)")
        }
    }
}

struct StatusSectionView: View {
    let statusName: String
    let statusManager: StatusManager
    let ideas: FetchedResults<Idea>
    let selectedTags: Set<Tag>
    @Binding var expandedStatuses: [String: Bool]
    let userSettings: UserSettings
    @Binding var ideaToDelete: Idea?
    @Binding var showDeleteConfirmation: Bool
    let deleteIdea: (Idea) -> Void
    let changeIdeaStatus: (Idea, String) -> Void
    @Binding var isSelectionMode: Bool
    @Binding var selectedIdeasForBulkTag: Set<Idea>
    
    private func shouldShowIdea(_ idea: Idea) -> Bool {
        guard let status = idea.status else { return false }
        
        // First check status visibility settings
        let statusVisible = switch status {
        case "Cancelled":
            userSettings.showCancelledIdeas
        case "Completed":
            userSettings.showCompletedIdeas
        case "Archived":
            userSettings.showArchivedIdeas
        default:
            true
        }
        
        guard statusVisible else { return false }
        
        // If no tags are selected, show all ideas
        if selectedTags.isEmpty {
            return true
        }
        
        // Check if idea has any of the selected tags
        guard let ideaTags = idea.tags as? Set<Tag> else { return false }
        return !selectedTags.isDisjoint(with: ideaTags)
    }
    
    var body: some View {
        if let status = statusManager.enabledStatuses.first(where: { $0.name == statusName }) {
            let ideasForStatus = ideas.filter { $0.status == status.name && shouldShowIdea($0) }
            if !ideasForStatus.isEmpty {
                DisclosureGroup(
                    isExpanded: Binding(
                        get: { expandedStatuses[status.name, default: true] },
                        set: { expandedStatuses[status.name] = $0 }
                    )
                ) {
                    ForEach(ideasForStatus, id: \.self) { idea in
                        HStack {
                            if isSelectionMode {
                                Image(systemName: selectedIdeasForBulkTag.contains(idea) ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(selectedIdeasForBulkTag.contains(idea) ? .blue : .gray)
                                    .font(.system(size: 22))
                            }

                            VStack(alignment: .leading, spacing: userSettings.showCompactView ? 2 : 4) {
                                Text(idea.title ?? "")
                                    .font(userSettings.showCompactView ? .subheadline : .headline)

                                if userSettings.showShortDesc && !userSettings.showCompactView {
                                    if let shortDesc = idea.shortDesc, !shortDesc.isEmpty {
                                        Text(shortDesc)
                                            .font(.subheadline)
                                    }
                                }

                                // Show tags only when NOT in selection mode
                                if !isSelectionMode {
                                    if let tags = idea.tags as? Set<Tag>, !tags.isEmpty {
                                        ScrollView(.horizontal, showsIndicators: false) {
                                            HStack(spacing: 4) {
                                                ForEach(Array(tags).sorted(by: { ($0.name ?? "") < ($1.name ?? "") }), id: \.objectID) { tag in
                                                    TagLabel(name: tag.name ?? "", color: Color(hex: tag.color ?? "#4B7BEC"))
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            Spacer()
                        }
                        .padding(.vertical, userSettings.showCompactView ? 10 : 20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                        .background(
                            Group {
                                if !isSelectionMode {
                                    NavigationLink(destination: IdeaView(idea: idea)) {
                                        EmptyView()
                                    }
                                    .opacity(0)
                                }
                            }
                        )
                        .if(isSelectionMode) { view in
                            view.onTapGesture {
                                if selectedIdeasForBulkTag.contains(idea) {
                                    selectedIdeasForBulkTag.remove(idea)
                                } else {
                                    selectedIdeasForBulkTag.insert(idea)
                                }
                            }
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                if userSettings.showDeleteConfirmation {
                                    ideaToDelete = idea
                                    showDeleteConfirmation = true
                                } else {
                                    deleteIdea(idea)
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .swipeActions(edge: .leading, allowsFullSwipe: false) {
                            // Quick status change buttons
                            if idea.status != "Completed" {
                                Button {
                                    changeIdeaStatus(idea, "Completed")
                                } label: {
                                    Label("Complete", systemImage: "checkmark.circle.fill")
                                }
                                .tint(.green)
                            }
                            
                            if idea.status != "Started" && idea.status != "Completed" {
                                Button {
                                    changeIdeaStatus(idea, "Started")
                                } label: {
                                    Label("Start", systemImage: "play.circle.fill")
                                }
                                .tint(.blue)
                            }
                            
                            if idea.status != "On Hold" {
                                Button {
                                    changeIdeaStatus(idea, "On Hold")
                                } label: {
                                    Label("Hold", systemImage: "pause.circle.fill")
                                }
                                .tint(.orange)
                            }
                        }
                    }
                    .padding(-15)
                } label: {
                    VStack(alignment: .center) {
                        HStack {
                            StatusLabel(name: status.name, color: status.color)
                            Spacer()
                            Text("\(ideasForStatus.count)")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(.trailing, 5)
                .accentColor(Color.colorPrimary)
            }
        }
    }
}

struct CustomNavigationLinkStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(NavigationLink("", destination: EmptyView()).opacity(0))
            .contentShape(Rectangle())
    }
}

extension View {
    func customNavigationLinkStyle() -> some View {
        self.modifier(CustomNavigationLinkStyle())
    }
}

struct DashboardTagFilterBar: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: Tag.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Tag.name, ascending: true)]
    ) private var allTags: FetchedResults<Tag>
    
    @Binding var selectedTags: Set<Tag>
    @Binding var showNewTagSheet: Bool
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // Clear button (X icon only)
                Button(action: { selectedTags.removeAll() }) {
                    Image("xmark")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(.gray)
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                }

                // New button opens tag creation sheet
                Button(action: { showNewTagSheet = true }) {
                    HStack(spacing: 4) {
                        Image("plus")
                            .resizable()
                            .renderingMode(.template)
                            .scaledToFit()
                            .frame(width: 12, height: 12)
                        Text("New").font(.caption).fontWeight(.medium)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.colorPrimary.opacity(0.1))
                    .foregroundColor(.colorPrimary)
                    .clipShape(Capsule())
                }


                // Tags inline after New (and editor if visible)
                ForEach(Array(allTags), id: \.objectID) { tag in
                    DashboardTagChip(
                        tag: tag,
                        isSelected: selectedTags.contains(tag),
                        onTap: {
                            if selectedTags.contains(tag) {
                                selectedTags.remove(tag)
                            } else {
                                selectedTags.insert(tag)
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 8)
        }
    }
}

struct DashboardTagChip: View {
    let tag: Tag
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text(tag.name ?? "Tag")
                .font(.caption)
                .fontWeight(.medium)
                .lineLimit(1)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                isSelected 
                    ? Color(hex: tag.color ?? "#4B7BEC")
                    : Color(hex: tag.color ?? "#4B7BEC").opacity(0.3)
            )
            .foregroundColor(
                isSelected 
                    ? .white
                    : Color(hex: tag.color ?? "#4B7BEC")
            )
            .clipShape(Capsule())
        }
    }
}

struct DashboardNewTagView: View {
    @Binding var tagName: String
    @Binding var tagColor: String
    let predefinedColors: [String]
    let onSave: (String, String) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tag Name")
                        .font(.headline)
                    TextField("Enter tag name", text: $tagName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tag Color")
                        .font(.headline)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                        ForEach(predefinedColors, id: \.self) { color in
                            Button(action: {
                                tagColor = color
                            }) {
                                Circle()
                                    .fill(Color(hex: color))
                                    .frame(width: 30, height: 30)
                                    .overlay(
                                        Circle()
                                            .stroke(
                                                tagColor == color ? Color.primary : Color.clear,
                                                lineWidth: 2
                                            )
                                    )
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("New Tag")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if !tagName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            onSave(tagName.trimmingCharacters(in: .whitespacesAndNewlines), tagColor)
                            dismiss()
                        }
                    }
                    .disabled(tagName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

struct TagLabel: View {
    let name: String
    let color: Color
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Text(name)
            .font(.system(size: 12, weight: .medium))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                ZStack {
                    Color.black.opacity(colorScheme == .dark ? 0.0 : 0.05)
                    color.opacity(0.35)
                }
            )
            .foregroundColor(color)
            .clipShape(Capsule())
    }
}

struct DashboardNewTagSheetView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @State private var tagName = ""
    @State private var selectedColor = "#4B7BEC"

    let predefinedColors = GlobalConstants.tagColors

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tag Name")
                        .font(.headline)
                    TextField("Enter tag name", text: $tagName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Tag Color")
                        .font(.headline)

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                        ForEach(predefinedColors, id: \.self) { color in
                            Button(action: {
                                selectedColor = color
                            }) {
                                Circle()
                                    .fill(Color(hex: color))
                                    .frame(width: 30, height: 30)
                                    .overlay(
                                        Circle()
                                            .stroke(
                                                selectedColor == color ? Color.primary : Color.clear,
                                                lineWidth: 2
                                            )
                                    )
                            }
                        }
                    }
                }

                Spacer()
            }
            .padding()
            .navigationTitle("New Tag")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if !tagName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            createNewTag()
                        }
                    }
                    .disabled(tagName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private func createNewTag() {
        let trimmedName = tagName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }

        let newTag = Tag(context: viewContext)
        newTag.id = UUID()
        newTag.name = trimmedName
        newTag.color = selectedColor

        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Error creating new tag: \(error)")
        }
    }
}

struct BulkTagSelectorView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @FetchRequest(
        entity: Tag.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Tag.name, ascending: true)]
    ) private var allTags: FetchedResults<Tag>

    @Binding var selectedIdeas: Set<Idea>
    @Binding var isSelectionMode: Bool
    @State private var selectedTags: Set<Tag> = []

    var body: some View {
        NavigationView {
            VStack {
                if selectedIdeas.isEmpty {
                    Text("No ideas selected")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List {
                        ForEach(Array(allTags), id: \.objectID) { tag in
                            HStack {
                                TagLabel(name: tag.name ?? "", color: Color(hex: tag.color ?? "#4B7BEC"))

                                Spacer()

                                if selectedTags.contains(tag) {
                                    Image("check")
                                        .resizable()
                                        .renderingMode(.template)
                                        .foregroundColor(Color.colorPrimary)
                                        .scaledToFit()
                                        .frame(width: 22, height: 22)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if selectedTags.contains(tag) {
                                    selectedTags.remove(tag)
                                } else {
                                    selectedTags.insert(tag)
                                }
                            }
                        }
                    }
                    .listStyle(.inset)
                }
            }
            .navigationTitle("Apply Tags to \(selectedIdeas.count) Ideas")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image("xmark")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(Color.colorPrimary)
                            .scaledToFit()
                            .frame(width: 22, height: 22)
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        applyTagsToSelectedIdeas()
                    }) {
                        Image("check")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(Color.colorPrimary)
                            .scaledToFit()
                            .frame(width: 22, height: 22)
                    }
                    .disabled(selectedTags.isEmpty)
                }
            }
        }
    }

    private func applyTagsToSelectedIdeas() {
        for idea in selectedIdeas {
            for tag in selectedTags {
                idea.addToTags(tag)
            }
            idea.updateDate = Date()
        }

        do {
            try viewContext.save()
            selectedIdeas.removeAll()
            isSelectionMode = false
            dismiss()
        } catch {
            print("Error applying tags: \(error)")
        }
    }
}

