import SwiftUI
import CoreData

struct IdeaTagSelectorView: View {
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
    
    let predefinedColors = [
        "#4B7BEC", "#26DE81", "#FC5C65", "#FD9644", 
        "#A55EEA", "#2BCBBA", "#E456F0", "#20BF6B",
        "#FF6B6B", "#54A0FF", "#5F27CD", "#00D2D3"
    ]
    
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
                            Button(action: {
                                if selectedTags.contains(tag) {
                                    selectedTags.remove(tag)
                                } else {
                                    selectedTags.insert(tag)
                                }
                            }) {
                                HStack {
                                    Circle()
                                        .fill(Color(hex: tag.color ?? "#4B7BEC"))
                                        .frame(width: 16, height: 16)
                                    
                                    Text(tag.name ?? "Unnamed Tag")
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    if selectedTags.contains(tag) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.colorPrimary)
                                    } else {
                                        Image(systemName: "circle")
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding(.vertical, 2)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .onDelete(perform: deleteTags)
                        
                        Button(action: {
                            showingNewTagSheet = true
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.colorPrimary)
                                Text("Create New Tag")
                                    .foregroundColor(.colorPrimary)
                                Spacer()
                            }
                            .padding(.vertical, 8)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .navigationTitle("Select Tags")
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
                        saveTags()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
                
                if !allTags.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("New Tag") {
                            showingNewTagSheet = true
                        }
                    }
                }
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
            .onAppear {
                // Initialize selectedTags with current idea tags
                if let ideaTags = idea.tags as? Set<Tag> {
                    selectedTags = ideaTags
                }
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
    
    private func deleteTags(offsets: IndexSet) {
        withAnimation {
            offsets.map { allTags[$0] }.forEach { tag in
                selectedTags.remove(tag)
                viewContext.delete(tag)
            }
            
            do {
                try viewContext.save()
            } catch {
                print("Error deleting tags: \(error)")
            }
        }
    }
}