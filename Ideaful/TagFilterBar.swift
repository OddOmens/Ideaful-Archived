import SwiftUI
import CoreData

struct TagFilterBar: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: Tag.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Tag.name, ascending: true)]
    ) private var allTags: FetchedResults<Tag>
    
    @Binding var selectedTags: Set<Tag>
    @State private var showingNewTagSheet = false
    @State private var newTagName = ""
    @State private var newTagColor = "#4B7BEC"
    
    let predefinedColors = [
        "#4B7BEC", "#26DE81", "#FC5C65", "#FD9644", 
        "#A55EEA", "#2BCBBA", "#E456F0", "#20BF6B",
        "#FF6B6B", "#54A0FF", "#5F27CD", "#00D2D3"
    ]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // Clear all filters button
                if !selectedTags.isEmpty {
                    Button(action: {
                        selectedTags.removeAll()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.caption)
                            Text("Clear")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.gray)
                        .clipShape(Capsule())
                    }
                }
                
                // Tag filter chips
                ForEach(Array(allTags), id: \.objectID) { tag in
                    TagChip(
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
                
                // Add new tag button
                Button(action: {
                    showingNewTagSheet = true
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle")
                            .font(.caption)
                        Text("Add Tag")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.colorPrimary.opacity(0.1))
                    .foregroundColor(.colorPrimary)
                    .clipShape(Capsule())
                }
            }
            .padding(.horizontal)
        }
        .sheet(isPresented: $showingNewTagSheet) {
            NewTagView(
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

struct TagChip: View {
    let tag: Tag
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                Circle()
                    .fill(Color(hex: tag.color ?? "#4B7BEC"))
                    .frame(width: 8, height: 8)
                
                Text(tag.name ?? "Tag")
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(1)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                isSelected 
                    ? Color(hex: tag.color ?? "#4B7BEC").opacity(0.2)
                    : Color.gray.opacity(0.1)
            )
            .foregroundColor(
                isSelected 
                    ? Color(hex: tag.color ?? "#4B7BEC")
                    : .primary
            )
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(
                        isSelected 
                            ? Color(hex: tag.color ?? "#4B7BEC")
                            : Color.clear,
                        lineWidth: 1
                    )
            )
        }
    }
}

struct NewTagView: View {
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