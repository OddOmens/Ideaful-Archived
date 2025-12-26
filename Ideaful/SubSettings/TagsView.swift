import SwiftUI
import CoreData

public struct TagsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var themeManager: ThemeManager
    
    @StateObject private var tagManager: TagManager
    
    @State private var showingCreateTag = false
    @State private var tagToDelete: Tag?
    @State private var showingDeleteAlert = false
    @State private var editingTag: Tag?
    @State private var showingEditTag = false
    
    public init(context: NSManagedObjectContext) {
        _tagManager = StateObject(wrappedValue: TagManager(context: context))
    }
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if tagManager.allTags.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image("memo")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(Color.colorPrimary.opacity(0.6))
                            .frame(width: 60, height: 60)
                        
                        Text("No Tags Yet".localized)
                            .font(.title2)
                            .bold()
                            .foregroundColor(Color.colorPrimary)
                        
                        Text("Create tags to organize your ideas".localized)
                            .foregroundColor(Color.colorPrimary.opacity(0.7))
                            .multilineTextAlignment(.center)
                        
                        Button(action: {
                            showingCreateTag = true
                        }) {
                            HStack {
                                Image("plus")
                                    .resizable()
                                    .renderingMode(.template)
                                    .foregroundColor(.white)
                                    .frame(width: 16, height: 16)
                                Text("Create Your First Tag".localized)
                                    .foregroundColor(.white)
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Color.colorPrimary)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                    Spacer()
                } else {
                    List {
                        ForEach(tagManager.allTags, id: \.self) { tag in
                            TagRowView(
                                tag: tag,
                                onEdit: {
                                    editingTag = tag
                                    showingEditTag = true
                                },
                                onDelete: {
                                    tagToDelete = tag
                                    showingDeleteAlert = true
                                }
                            )
                            .listRowBackground(Color.clear)
                        }
                    }
                    .listStyle(PlainListStyle())
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Tags".localized)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
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
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingCreateTag = true
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
        .sheet(isPresented: $showingCreateTag) {
            CreateTagView(tagManager: tagManager)
        }
        .sheet(isPresented: $showingEditTag) {
            if let tag = editingTag {
                EditTagView(tag: tag, tagManager: tagManager)
            }
        }
        .alert(isPresented: $showingDeleteAlert) {
            Alert(
                title: Text("Delete Tag".localized),
                message: Text("Are you sure you want to delete this tag? It will be removed from all ideas.".localized),
                primaryButton: .destructive(Text("Delete".localized)) {
                    if let tag = tagToDelete {
                        tagManager.deleteTag(tag)
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }
}

struct TagRowView: View {
    let tag: Tag
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    public var body: some View {
        HStack(spacing: 16) {
            TagView(tag: tag)
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(tag.sortedIdeas.count) " + (tag.sortedIdeas.count == 1 ? "idea".localized : "ideas".localized))
                    .font(.caption)
                    .foregroundColor(Color.colorPrimary.opacity(0.7))
                
                if let createDate = tag.createDate {
                    Text(createDate, style: .date)
                        .font(.caption2)
                        .foregroundColor(Color.colorPrimary.opacity(0.5))
                }
            }
            
            Menu {
                Button(action: onEdit) {
                    Label("Edit".localized, systemImage: "pencil")
                }
                
                Button(role: .destructive, action: onDelete) {
                    Label("Delete".localized, systemImage: "trash")
                }
            } label: {
                Image("menu")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(Color.colorPrimary)
                    .frame(width: 20, height: 20)
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
}

struct EditTagView: View {
    @ObservedObject var tag: Tag
    @ObservedObject var tagManager: TagManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var tagName: String
    @State private var selectedColor: String
    
    init(tag: Tag, tagManager: TagManager) {
        self.tag = tag
        self.tagManager = tagManager
        _tagName = State(initialValue: tag.displayName)
        _selectedColor = State(initialValue: tag.color ?? "colorPrimary")
    }
    
    public var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tag Name".localized)
                        .font(.headline)
                    TextField("Enter tag name...".localized, text: $tagName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Color".localized)
                        .font(.headline)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 10) {
                        ForEach(tagManager.getAvailableColors(), id: \.0) { colorName, color in
                            Button(action: {
                                selectedColor = colorName
                            }) {
                                Circle()
                                    .fill(color)
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.primary, lineWidth: selectedColor == colorName ? 3 : 0)
                                    )
                            }
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Ideas".localized)
                        .font(.headline)
                    
                    Text("\(tag.sortedIdeas.count) " + (tag.sortedIdeas.count == 1 ? "idea uses this tag".localized : "ideas use this tag".localized))
                        .font(.caption)
                        .foregroundColor(Color.colorPrimary.opacity(0.7))
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Edit Tag".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel".localized) {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save".localized) {
                        saveTag()
                    }
                    .disabled(tagName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private func saveTag() {
        tagManager.updateTag(tag, name: tagName, color: selectedColor)
        presentationMode.wrappedValue.dismiss()
    }
}