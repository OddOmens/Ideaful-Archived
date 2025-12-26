import SwiftUI
import CoreData

struct TagsManagementView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: Tag.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Tag.name, ascending: true)]
    ) private var allTags: FetchedResults<Tag>
    
    @State private var showingNewTagSheet = false
    @State private var editingTag: Tag?
    @State private var newTagName = ""
    @State private var newTagColor = "#4B7BEC"
    @State private var editTagName = ""
    @State private var editTagColor = "#4B7BEC"
    
    let predefinedColors = GlobalConstants.tagColors
    
    var body: some View {
        NavigationView {
            VStack {
            if allTags.isEmpty {
                VStack(spacing: 16) {
                    Image("tag")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(.gray)
                        .scaledToFit()
                        .frame(width: 48, height: 48)
                    
                    Text("No tags yet")
                        .font(.title2)
                        .fontWeight(.medium)
                    
                    Text("Create your first tag to organize your ideas")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Button("Create Tag") {
                        showingNewTagSheet = true
                    }
                    .padding(.top, 8)
                }
                .padding()
            } else {
                List {
                    ForEach(Array(allTags), id: \.objectID) { tag in
                        HStack {
                            TagsManagementTagLabel(name: tag.name ?? "", color: Color(hex: tag.color ?? "#4B7BEC"))
                            
                            Spacer()
                            
                            Text("\(ideaCount(for: tag))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                deleteTag(tag)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .swipeActions(edge: .leading, allowsFullSwipe: false) {
                            Button {
                                editTagName = tag.name ?? ""
                                editTagColor = tag.color ?? "#4B7BEC"
                                editingTag = tag
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(.blue)
                        }
                    }
                }
                .listStyle(.inset)
            }
        }
        .navigationTitle("Tags")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                if !allTags.isEmpty {
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
            }
        }
        .sheet(isPresented: $showingNewTagSheet) {
            TagsManagementNewTagView(
                tagName: $newTagName,
                tagColor: $newTagColor,
                predefinedColors: predefinedColors,
                onSave: { name, color in
                    createNewTag(name: name, color: color)
                }
            )
        }
        .sheet(item: $editingTag) { tag in
            TagsManagementEditTagView(
                tag: tag,
                tagName: $editTagName,
                tagColor: $editTagColor,
                predefinedColors: predefinedColors,
                onSave: { name, color in
                    updateTag(tag, name: name, color: color)
                }
            )
            .presentationDetents([.medium])
        }
    }
    
    private func ideaCount(for tag: Tag) -> Int {
        guard let ideas = tag.ideas as? Set<Idea> else { return 0 }
        return ideas.count
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
    
    private func updateTag(_ tag: Tag, name: String, color: String) {
        tag.name = name
        tag.color = color
        
        do {
            try viewContext.save()
            editingTag = nil
            editTagName = ""
            editTagColor = "#4B7BEC"
        } catch {
            print("Error updating tag: \(error)")
        }
    }
    
    private func deleteTag(_ tag: Tag) {
        viewContext.delete(tag)
        
        do {
            try viewContext.save()
        } catch {
            print("Error deleting tag: \(error)")
        }
    }
}


struct TagsManagementNewTagView: View {
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

struct TagsManagementTagLabel: View {
    let name: String
    let color: Color
    
    var body: some View {
        Text(name)
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(color)
            .clipShape(Capsule())
    }
}

struct TagsManagementEditTagView: View {
    let tag: Tag
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
            .navigationTitle("Edit Tag")
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