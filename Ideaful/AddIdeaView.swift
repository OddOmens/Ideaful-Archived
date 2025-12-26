import SwiftUI
import CoreData

struct AddIdeaView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext

    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var userSettings: UserSettings
    @EnvironmentObject var iconManager: IconManager
    @EnvironmentObject var statusManager: StatusManager
    
    @State private var existingIdea: Idea?
    @State private var title: String
    @State private var shortDesc: String
    @State private var notes: String
    @State private var selectedStatus: String
    @State private var showingStatusPicker = false
    @State private var selectedTags: Set<Tag> = []
    @State private var showingTagPicker = false
    
    @FocusState private var focusedField: Field?
    
    enum Field: Hashable {
        case title
        case description
    }
    
    public init(idea: Idea? = nil) {
        _existingIdea = State(initialValue: idea)
        _title = State(initialValue: idea?.title ?? "")
        _notes = State(initialValue: idea?.notes ?? "")
        _shortDesc = State(initialValue: idea?.shortDesc ?? "")
        _selectedStatus = State(initialValue: idea?.status ?? "Unassigned")
        _selectedTags = State(initialValue: (idea?.tags as? Set<Tag>) ?? [])
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    titleSection
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                        .background(Color.gray.opacity(0.08))
                        .cornerRadius(12)

                    statusSection
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                        .background(Color.gray.opacity(0.08))
                        .cornerRadius(12)

                    tagsSection
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                        .background(Color.gray.opacity(0.08))
                        .cornerRadius(12)

                    descriptionSection
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                        .background(Color.gray.opacity(0.08))
                        .cornerRadius(12)
                }
                .padding()
            }
            .scrollDismissesKeyboard(.immediately)
            .navigationTitle("A New Idea".localized)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack(spacing: 10) {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image("xmark")
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
                            saveIdeaIfNotEmpty()
                            presentationMode.wrappedValue.dismiss()
                        }) {
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
    
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label {
                Text("Title".localized)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            } icon: {
                Image(systemName: "lightbulb.fill")
                    .font(.caption)
                    .foregroundColor(Color.colorPrimary)
            }
            ZStack(alignment: .topLeading) {
                TextEditor(text: Binding(
                    get: { title },
                    set: { newValue in
                        if newValue.contains("\n") {
                            title = newValue.replacingOccurrences(of: "\n", with: "")
                            focusedField = nil
                            saveIdeaIfNotEmpty()
                        } else if newValue.count > 85 {
                            title = String(newValue.prefix(85))
                        } else {
                            title = newValue
                        }
                    }
                ))
                .scrollDisabled(true)
                .focused($focusedField, equals: .title)
                .onChange(of: title) { _ in
                    saveIdeaIfNotEmpty()
                }
                .padding([.leading, .trailing], -5)
                .padding(.bottom, -6)
                .frame(height: 55)
                .foregroundColor(Color.colorPrimary)
                .scrollContentBackground(.hidden)

                if title.isEmpty {
                    Text("Enter a title for your idea...")
                        .foregroundColor(Color.colorPrimary.opacity(0.5))
                        .padding(.top, 8)
                        .padding(.leading, -1)
                }
            }
            Text("\(85 - title.count) " + "characters remaining".localized)
                .font(.footnote)
                .padding(.top, 1)
        }
    }

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label {
                Text("Description".localized)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            } icon: {
                Image(systemName: "text.alignleft")
                    .font(.caption)
                    .foregroundColor(Color.colorPrimary)
            }
            ZStack(alignment: .topLeading) {
                TextEditor(text: Binding(
                    get: { shortDesc },
                    set: { newValue in
                        if newValue.contains("\n") {
                            shortDesc = newValue.replacingOccurrences(of: "\n", with: "")
                            focusedField = nil
                        } else if newValue.count > 85 {
                            shortDesc = String(newValue.prefix(85))
                        } else {
                            shortDesc = newValue
                        }
                    }
                ))
                .focused($focusedField, equals: .description)
                .onChange(of: shortDesc) { _ in
                    saveIdeaIfNotEmpty()
                }
                .padding([.leading, .trailing], -5)
                .padding(.bottom, -6)
                .frame(height: 55)
                .foregroundColor(Color.colorPrimary)
                .scrollContentBackground(.hidden)

                if shortDesc.isEmpty {
                    Text("Enter a short description for your idea...")
                        .foregroundColor(Color.colorPrimary.opacity(0.5))
                        .padding(.top, 8)
                        .padding(.leading, -1)
                }
            }
            Text("\(85 - shortDesc.count) " + "characters remaining".localized)
                .font(.footnote)
                .padding(.top, 1)
        }
    }
    
    private var statusSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label {
                Text("Status".localized)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            } icon: {
                Image(systemName: "flag.fill")
                    .font(.caption)
                    .foregroundColor(Color.colorPrimary)
            }
            
            Button(action: {
                showingStatusPicker = true
            }) {
                HStack {
                    StatusLabel(name: selectedStatus, color: GlobalConstants.statusColors[selectedStatus] ?? .gray)
                    Spacer()
                    Image("chevron-right")
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .foregroundColor(Color.colorPrimary)
                        .frame(width: 22, height: 22)
                        .padding(.leading, -20)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            .sheet(isPresented: $showingStatusPicker) {
                NavigationView {
                    StatusSelectorView(selectedStatus: $selectedStatus)
                }
            }
        }
    }
    
    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label {
                Text("Tags".localized)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            } icon: {
                Image(systemName: "tag.fill")
                    .font(.caption)
                    .foregroundColor(Color.colorPrimary)
            }
            
            Button(action: {
                showingTagPicker = true
            }) {
                HStack {
                    if selectedTags.isEmpty {
                        Text("Add tags...")
                            .foregroundColor(Color.colorPrimary.opacity(0.6))
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 6) {
                                ForEach(Array(selectedTags).sorted(by: { ($0.name ?? "") < ($1.name ?? "") }), id: \.objectID) { tag in
                                    TagLabel(name: tag.name ?? "", color: Color(hex: tag.color ?? "#4B7BEC"))
                                }
                            }
                        }
                    }
                    
                    Spacer()
                    
                    Image("chevron-right")
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .foregroundColor(Color.colorPrimary)
                        .frame(width: 22, height: 22)
                        .padding(.leading, -20)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            .sheet(isPresented: $showingTagPicker) {
                NavigationView {
                    TagPickerView(selectedTags: $selectedTags)
                }
            }
        }
    }
    
    func saveIdeaIfNotEmpty() {
        if !title.isEmpty || !shortDesc.isEmpty || !notes.isEmpty {
            saveIdea()
        }
    }
    
    func saveIdea() {
        let ideaToSave: Idea
        if let idea = existingIdea {
            ideaToSave = idea
        } else {
            ideaToSave = Idea(context: viewContext)
            existingIdea = ideaToSave
        }
        
        ideaToSave.title = title
        ideaToSave.shortDesc = shortDesc
        ideaToSave.notes = notes
        ideaToSave.status = selectedStatus
        ideaToSave.createDate = Date()
        ideaToSave.updateDate = Date()
        
        // Clear existing tags and add selected ones
        if let currentTags = ideaToSave.tags as? Set<Tag> {
            for tag in currentTags {
                ideaToSave.removeFromTags(tag)
            }
        }
        for tag in selectedTags {
            ideaToSave.addToTags(tag)
        }
        
        do {
            try viewContext.save()
            updateStats(viewContext: viewContext, ideasCreated: 1)
            checkAndUnlockAchievements(context: viewContext)
            print("Ideaful: Idea saved successfully")
        } catch {
            print("Ideaful: Unable to save new idea \(error)")
        }
    }
}

struct TagPickerView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @FetchRequest(
        entity: Tag.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Tag.name, ascending: true)]
    ) private var allTags: FetchedResults<Tag>
    
    @Binding var selectedTags: Set<Tag>
    @State private var showingNewTagSheet = false
    @State private var newTagName = ""
    @State private var newTagColor = "#4B7BEC"
    
    let predefinedColors = GlobalConstants.tagColors
    
    var body: some View {
        List {
            ForEach(Array(allTags), id: \.objectID) { tag in
                Button(action: {
                    if selectedTags.contains(tag) {
                        selectedTags.remove(tag)
                    } else {
                        selectedTags.insert(tag)
                    }
                }) {
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
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .listStyle(.inset)
        .navigationTitle("Select Tags")
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
                    showingNewTagSheet = true
                }) {
                    Image("plus")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(Color.colorPrimary)
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                }
            }
        }
        .sheet(isPresented: $showingNewTagSheet) {
            AddIdeaNewTagView(
                tagName: $newTagName,
                tagColor: $newTagColor,
                predefinedColors: predefinedColors,
                onSave: { name, color in
                    createNewTag(name: name, color: color)
                }
            )
        }
    }
    
    private func createNewTag(name: String, color: String) {
        let newTag = Tag(context: viewContext)
        newTag.id = UUID()
        newTag.name = name
        newTag.color = color
        
        do {
            try viewContext.save()
            newTagName = ""
            newTagColor = "#4B7BEC"
        } catch {
            print("Error creating new tag: \(error)")
        }
    }
}

struct AddIdeaNewTagView: View {
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

