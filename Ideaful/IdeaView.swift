import SwiftUI
import CoreData
import PhotosUI

extension Idea {
    var imagePathsArray: [String] {
        get {
            // Convert the string to an array by splitting it by commas or use JSON decoding if using JSON
            return self.imagePaths?.components(separatedBy: ",") ?? []
        }
        set {
            // Convert the array back to a comma-separated string or JSON
            self.imagePaths = newValue.joined(separator: ",")
        }
    }
    
    var images: [UIImage] {
        get {
            return imagePathsArray.compactMap { imagePath in
                // Load image from file path
                guard !imagePath.isEmpty else { return nil }
                let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let imageURL = documentsPath.appendingPathComponent(imagePath)
                guard let imageData = try? Data(contentsOf: imageURL) else { return nil }
                return UIImage(data: imageData)
            }
        }
        set {
            // Save images to files and store paths
            var newImagePaths: [String] = []
            for (index, image) in newValue.enumerated() {
                if let imageData = image.jpegData(compressionQuality: 0.8) {
                    let fileName = "idea_\(self.id?.uuidString ?? UUID().uuidString)_\(index).jpg"
                    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    let fileURL = documentsPath.appendingPathComponent(fileName)
                    
                    do {
                        try imageData.write(to: fileURL)
                        newImagePaths.append(fileName)
                    } catch {
                        print("Failed to save image: \(error)")
                    }
                }
            }
            self.imagePathsArray = newImagePaths
        }
    }
}

struct IdeaView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext

    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var userSettings: UserSettings
    @EnvironmentObject var iconManager: IconManager
    @EnvironmentObject var statusManager: StatusManager

    @ObservedObject var idea: Idea

    @State private var isTasksButtonEnabled: Bool = UserDefaults.standard.bool(forKey: "isTasksButtonEnabled")
    @State private var isShortDescEnabled: Bool = UserDefaults.standard.bool(forKey: "isShortDescEnabled")

    @State private var showingDeletionAlert = false
    @State private var showingStatusPicker = false
    @State private var showingTagPicker = false
    @State private var showingTasks = false
    @State private var showingHalfSheet = false
    @State private var showingNoteDetail = false
    @State private var showDeleteConfirmation = false
    
    @State private var noteToDelete: Note?
    @State private var showDeleteNoteConfirmation = false
    
    @State private var selectedNote: Note?

    @State private var title: String
    @State private var shortDesc: String
    @State private var newNoteTitle: String = ""
    @State private var newNoteText: String = ""
    @State private var selectedStatus: String
    
    @State private var images: [UIImage] = []
    @State private var selectedImageIndex: Int?
    @State private var showingFullImage = false
    @State private var selectedItems: [PhotosPickerItem] = []

    @FetchRequest private var tasks: FetchedResults<IdeaTask>
    @FetchRequest private var notes: FetchedResults<Note>

    @State private var ideaInfoDetent = PresentationDetent.medium
    
    @FocusState private var focusedField: Field?
    
    enum Field: Hashable {
        case title
        case description
    }

    init(idea: Idea) {
        self.idea = idea
        _title = State(initialValue: idea.title ?? "")
        _shortDesc = State(initialValue: idea.shortDesc ?? "")
        _selectedStatus = State(initialValue: idea.status ?? "Unassigned")
        
        _tasks = FetchRequest(
            entity: IdeaTask.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \IdeaTask.tasked, ascending: true)],
            predicate: NSPredicate(format: "idea == %@", idea),
            animation: .default
        )

        _notes = FetchRequest(
            entity: Note.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Note.title, ascending: true)],
            predicate: NSPredicate(format: "idea == %@", idea),
            animation: .default
        )

        _images = State(initialValue: idea.images)
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

                    imagesSection
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                        .background(Color.gray.opacity(0.08))
                        .cornerRadius(12)

                    notesSection
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                        .background(Color.gray.opacity(0.08))
                        .cornerRadius(12)
                }
                .padding()
            }
            .scrollDismissesKeyboard(.immediately)
            .navigationTitle("The Idea".localized)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack(spacing: 10) {
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
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 10) {
                        /*NavigationLink(destination: IdeaInformationView(idea: idea)) {
                         Image("file-info-alt")
                         .resizable()
                         .renderingMode(.template)
                         .foregroundColor(Color.colorPrimary)
                         .scaledToFit()
                         .frame(width: 22, height: 22)
                         }*/
                        
                        if userSettings.showTasks {
                            NavigationLink(destination: TasksView(idea: idea)) {
                                Image("list")
                                    .resizable()
                                    .renderingMode(.template)
                                    .foregroundColor(Color.colorPrimary)
                                    .scaledToFit()
                                    .frame(width: 22, height: 22)
                                    
                                    .overlay(taskCountOverlay)
                            }
                        }
                    }
                    HStack {
                        Button(action: {
                            if userSettings.showDeleteConfirmation {
                                showDeleteConfirmation = true
                            } else {
                                deleteIdea()
                            }
                        }) {
                            Image("trash")
                                .resizable()
                                .renderingMode(.template)
                                .foregroundColor(Color.colorRed)
                                .scaledToFit()
                                .frame(width: 22, height: 22)
                                .padding(.leading, 5)
                        }
                        .alert(isPresented: $showDeleteConfirmation) {
                            Alert(
                                title: Text("Delete Idea".localized),
                                message: Text("Are you sure you want to delete this idea?".localized),
                                primaryButton: .destructive(Text("Delete")) {
                                    deleteIdea()
                                },
                                secondaryButton: .cancel()
                            )
                        }
                    }
                }
            }
            .onAppear {
                checkAndUnlockAchievements(context: viewContext)
                images = idea.images
            }
            .onChange(of: selectedStatus) { newValue in
                saveStatusChanges()
            }
            .alert(isPresented: $showDeleteNoteConfirmation) {
                Alert(
                    title: Text("Delete Note"),
                    message: Text("Are you sure you want to delete this note?"),
                    primaryButton: .destructive(Text("Delete")) {
                        if let noteToDelete = noteToDelete {
                            delete(note: noteToDelete)
                        }
                    },
                    secondaryButton: .cancel()
                )
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
                    saveChanges(shouldDismiss: false)
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
                .scrollDisabled(true)
                .focused($focusedField, equals: .description)
                .onChange(of: shortDesc) { _ in
                    saveChanges(shouldDismiss: false)
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
                    if let ideaTags = idea.tags as? Set<Tag>, !ideaTags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 6) {
                                ForEach(Array(ideaTags).sorted(by: { ($0.name ?? "") < ($1.name ?? "") }), id: \.objectID) { tag in
                                    TagLabel(name: tag.name ?? "", color: Color(hex: tag.color ?? "#4B7BEC"))
                                }
                            }
                        }
                    } else {
                        Text("Add tags...")
                            .foregroundColor(Color.colorPrimary.opacity(0.6))
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
                    IdeaTagPickerView(idea: idea)
                }
            }
        }
    }
    
    private var imagesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label {
                Text("Inspirational Images")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            } icon: {
                Image(systemName: "photo.fill")
                    .font(.caption)
                    .foregroundColor(Color.colorPrimary)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    if images.count < 10 {
                        PhotosPicker(selection: $selectedItems, maxSelectionCount: 10 - images.count, matching: .images) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .strokeBorder(Color.colorPrimary, lineWidth: 2)
                                    .frame(width: 80, height: 80)
                                
                                Image("plus")
                                    .resizable()
                                    .renderingMode(.template)
                                    .foregroundColor(Color.colorPrimary)
                                    .scaledToFit()
                                    .frame(width: 22, height: 22)
                                    
                            }
                        }
                        .onChange(of: selectedItems) { _ in
                            addSelectedImages()
                        }
                    }
                    
                    ForEach(images.indices, id: \.self) { index in
                        NavigationLink(destination: FullImageView(
                            images: $images,
                            imageIndex: index,
                            idea: idea,
                            viewContext: viewContext
                        )) {
                            Image(uiImage: images[index])
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                deleteImage(at: index)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }.padding(.bottom, -10)
        }
    }
    
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label {
                    Text("Notes".localized)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                } icon: {
                    Image(systemName: "note.text")
                        .font(.caption)
                        .foregroundColor(Color.colorPrimary)
                }
                Spacer()
                NavigationLink(destination: NoteDetailView(note: selectedNote ?? Note(context: viewContext), idea: idea), isActive: $showingNoteDetail) {
                    EmptyView()
                }
                .opacity(0)

                Button(action: {
                    let newNote = Note(context: viewContext)
                    newNote.idea = idea
                    newNote.timeStamp = Date()
                    selectedNote = newNote
                    showingNoteDetail = true
                }) {
                    Image("plus")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(Color.colorPrimary)
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                }
            }

            if notes.isEmpty {
                Text("No notes yet. Tap + to add one.")
                    .foregroundColor(Color.colorPrimary.opacity(0.5))
                    .padding(.vertical, 8)
            } else {
                List {
                    ForEach(notes, id: \.self) { note in
                        ZStack {
                            HStack {
                                Rectangle()
                                    .frame(width: 2)
                                    .foregroundColor(Color.colorPrimary)
                                VStack(alignment: .leading) {
                                    Text(note.title ?? "")
                                        .bold()
                                    Text(note.text?.prefix(72) ?? "")
                                }
                                Spacer()
                            }
                            NavigationLink(destination: NoteDetailView(note: note, idea: idea)) {
                                EmptyView()
                            }.opacity(0)
                        }
                        .contentShape(Rectangle())
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                        .padding(.bottom, 8)
                    }
                    .onDelete { indices in
                        indices.forEach { index in
                            let note = notes[index]
                            delete(note: note)
                        }
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
                .frame(height: CGFloat(notes.count * 60))
            }
        }
    }
    
    private func delete(note: Note) {
        viewContext.delete(note)
        do {
            try viewContext.save()
            updateStats(viewContext: viewContext, notesDeleted: 1)
        } catch {
            print("Failed to delete note: \(error)")
        }
    }

    private var taskCountOverlay: some View {
        let uncompletedTasksCount = tasks.filter { !$0.isCompleted }.count

        return ZStack {
            if userSettings.showTaskCount {
                Circle()
                    .fill(Color.colorGreen)
                    .frame(width: 14, height: 14)
                Text(uncompletedTasksCount > 99 ? "99" : "\(uncompletedTasksCount)")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .offset(x: 10, y: -8)
        .opacity(uncompletedTasksCount > 0 ? 1 : 0)
    }

    private func saveChanges(shouldDismiss: Bool = true) {
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            print("Ideaful: Title can't be empty.")
            return
        }

        idea.title = title
        idea.shortDesc = shortDesc
        idea.updateDate = Date()
        idea.status = selectedStatus
        idea.images = self.images

        do {
            try viewContext.save()
            checkAndUnlockAchievements(context: viewContext)
            print("Ideaful: Changes saved successfully.")
        } catch {
            print("Ideaful: Failed to save idea \(error)")
        }

        if shouldDismiss {
            presentationMode.wrappedValue.dismiss()
        }
    }

    private func saveStatusChanges() {
        let initialStatus = idea.status
        idea.status = selectedStatus

        do {
            try viewContext.save()
            checkAndUnlockAchievements(context: viewContext)
            print("Ideaful: Status changes saved successfully.")

            if selectedStatus == "Completed".localized {
                updateStats(viewContext: viewContext, ideasCompleted: 1)
            } else if selectedStatus == "Cancelled".localized {
                updateStats(viewContext: viewContext, ideasCancelled: 1)
            }
        } catch {
            print("Ideaful: Failed to save idea status \(error)")
        }
    }

    private func deleteIdea() {
        viewContext.delete(idea)
        do {
            try viewContext.save()
            checkAndUnlockAchievements(context: viewContext)
            updateStats(viewContext: viewContext, ideasDeleted: 1)
        } catch {
            print("Ideaful: Failed to delete idea \(error)")
        }

        presentationMode.wrappedValue.dismiss()
    }
    
    private func addSelectedImages() {
        for item in selectedItems {
            item.loadTransferable(type: Data.self) { result in
                switch result {
                case .success(let data):
                    if let data = data, let uiImage = UIImage(data: data) {
                        DispatchQueue.main.async {
                            images.append(uiImage)
                            idea.images = images
                            try? viewContext.save()
                        }
                    }
                case .failure(let error):
                    print("Error loading image: \(error.localizedDescription)")
                }
            }
        }
        selectedItems.removeAll()
    }
    
    private func deleteImage(at index: Int) {
        images.remove(at: index)
        idea.images = images
        
        do {
            try viewContext.save()
        } catch {
            print("Failed to delete image and save context: \(error)")
        }
    }

    func smartTruncate(text: String, maxLength: Int) -> String {
        guard text.count > maxLength else { return text }
        
        let truncated = String(text.prefix(maxLength))
        let lastChar = truncated.last!
        
        if [".", "?", "!"].contains(lastChar) {
            return truncated
        } else if [",", " "].contains(lastChar) || truncated.count == 1 {
            return String(truncated.dropLast()) + "..."
        } else {
            return truncated + "..."
        }
    }
}


private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    return formatter
}()

struct NoteDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    
    @EnvironmentObject var themeManager: ThemeManager

    @ObservedObject var note: Note
    let idea: Idea

    @State private var title: String = ""
    @State private var text: String = ""
    @State private var showingDeleteAlert = false

    init(note: Note, idea: Idea) {
        self.note = note
        self.idea = idea
        _title = State(initialValue: note.title ?? "")
        _text = State(initialValue: note.text ?? "")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            TextField("Title...", text: $title, prompt: Text("Title..".localized), axis: .vertical)
                .font(.system(size: 20))
                .bold()
            TextField("", text: $text, prompt: Text("Notes...".localized), axis: .vertical)
            
            Spacer()
        }
        .padding()
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(note.isNew ? "A New Note".localized : "A Note".localized)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    if note.isNew && title.trimmingCharacters(in: .whitespaces).isEmpty && text.trimmingCharacters(in: .whitespaces).isEmpty {
                        viewContext.delete(note)
                    }
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

            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 16) {
                    if !note.isNew {
                        Button(action: {
                            self.showingDeleteAlert = true
                        }) {
                            Image("trash")
                                .resizable()
                                .renderingMode(.template)
                                .foregroundColor(.red)
                                .scaledToFit()
                                .frame(width: 22, height: 22)
                        }
                        .alert(isPresented: $showingDeleteAlert) {
                            Alert(
                                title: Text("Delete Note"),
                                message: Text("Are you sure you want to delete this note?"),
                                primaryButton: .destructive(Text("Delete")) {
                                    deleteNote()
                                },
                                secondaryButton: .cancel()
                            )
                        }
                    }

                    Button(action: {
                        saveChanges()
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image("check")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(Color.colorPrimary)
                            .scaledToFit()
                            .frame(width: 22, height: 22)
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty && text.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func saveChanges() {
        if !title.trimmingCharacters(in: .whitespaces).isEmpty || !text.trimmingCharacters(in: .whitespaces).isEmpty {
            note.title = title
            note.text = text
            note.timeStamp = Date()

            // Establish the relationship
            if note.idea != idea {
                note.idea = idea
                idea.addToIdeaNotes(note)
            }

            do {
                try viewContext.save()
                print("Note saved successfully. Title: \(title), Text: \(text)")
                print("Note idea relationship: \(note.idea?.title ?? "nil")")
            } catch {
                print("Failed to save note: \(error)")
            }
        } else if note.isNew {
            print("Deleting empty note")
            viewContext.delete(note)
        }
    }

    private func deleteNote() {
        viewContext.delete(note)
        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Failed to delete note: \(error)")
        }
    }
}

extension Note {
    var isNew: Bool {
        return self.managedObjectContext?.insertedObjects.contains(self) ?? false
    }
}
struct FullImageView: View {
    @Binding var images: [UIImage]
    var imageIndex: Int
    var idea: Idea
    var viewContext: NSManagedObjectContext

    @State private var showingDeleteAlert = false
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            if imageIndex < images.count {
                Image(uiImage: images[imageIndex])
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Text("Image not available")
                    .foregroundColor(.gray)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Image".localized)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
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
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    Button(action: {
                        self.showingDeleteAlert = true
                    }) {
                        Image("trash")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(.red)
                            .scaledToFit()
                            .frame(width: 22, height: 22)
                            
                    }
                    .alert(isPresented: $showingDeleteAlert) {
                        Alert(
                            title: Text("Delete Image"),
                            message: Text("Are you sure you want to delete this image?"),
                            primaryButton: .destructive(Text("Delete")) {
                                deleteImage()
                            },
                            secondaryButton: .cancel()
                        )
                    }
                }
            }
        }
    }
    
    private func deleteImage() {
        // Ensure we have a valid index before proceeding
        guard imageIndex < images.count else {
            print("Invalid index")
            return
        }

        // Remove the image from the array
        images.remove(at: imageIndex)
        
        // Update the Core Data entity's images array
        idea.images = images
        
        // Save the updated context
        do {
            try viewContext.save()
            // Dismiss the view after successful deletion
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Failed to delete image and save context: \(error)")
        }
    }
}

struct IdeaTagPickerView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @FetchRequest(
        entity: Tag.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Tag.name, ascending: true)]
    ) private var allTags: FetchedResults<Tag>
    
    @ObservedObject var idea: Idea
    @State private var selectedTags: Set<Tag> = []
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
                    saveTags()
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
            IdeaNewTagView(
                tagName: $newTagName,
                tagColor: $newTagColor,
                predefinedColors: predefinedColors,
                onSave: { name, color in
                    createNewTag(name: name, color: color)
                }
            )
        }
        .onAppear {
            // Initialize selectedTags with current idea tags
            if let ideaTags = idea.tags as? Set<Tag> {
                selectedTags = ideaTags
            }
        }
    }
    
    private func saveTags() {
        // Clear existing tags
        if let currentTags = idea.tags as? Set<Tag> {
            for tag in currentTags {
                idea.removeFromTags(tag)
            }
        }
        
        // Add selected tags
        for tag in selectedTags {
            idea.addToTags(tag)
        }
        
        idea.updateDate = Date()
        
        do {
            try viewContext.save()
        } catch {
            print("Error saving tags to idea: \(error)")
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

struct IdeaNewTagView: View {
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

