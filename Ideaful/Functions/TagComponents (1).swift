import SwiftUI
import CoreData

struct TagView: View {
    let tag: Tag
    let onRemove: (() -> Void)?
    
    init(tag: Tag, onRemove: (() -> Void)? = nil) {
        self.tag = tag
        self.onRemove = onRemove
    }
    
    var body: some View {
        HStack(spacing: 6) {
            Text(tag.displayName)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white)
            
            if let onRemove = onRemove {
                Button(action: onRemove) {
                    Image("xmark")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(.white.opacity(0.8))
                        .frame(width: 8, height: 8)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(tag.colorValue)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct TagInput: View {
    @Binding var selectedTags: [Tag]
    @ObservedObject var tagManager: TagManager
    let context: NSManagedObjectContext
    
    @State private var inputText = ""
    @State private var isShowingTagSelector = false
    @State private var showingCreateTag = false
    
    var filteredTags: [Tag] {
        if inputText.isEmpty {
            return tagManager.allTags.filter { tag in
                !selectedTags.contains(tag)
            }
        } else {
            return tagManager.allTags.filter { tag in
                !selectedTags.contains(tag) && 
                (tag.name?.lowercased().contains(inputText.lowercased()) ?? false)
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !selectedTags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(selectedTags, id: \.self) { tag in
                            TagView(tag: tag) {
                                removeTag(tag)
                            }
                        }
                    }
                    .padding(.horizontal, 2)
                }
            }
            
            HStack {
                TextField("Add tags...".localized, text: $inputText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onSubmit {
                        createTagFromInput()
                    }
                
                Button(action: {
                    isShowingTagSelector = true
                }) {
                    Image("plus")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(Color.colorPrimary)
                        .frame(width: 20, height: 20)
                }
                .sheet(isPresented: $isShowingTagSelector) {
                    TagSelectorView(
                        selectedTags: $selectedTags,
                        tagManager: tagManager,
                        inputText: $inputText
                    )
                }
            }
            
            if !inputText.isEmpty && !filteredTags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(filteredTags.prefix(5), id: \.self) { tag in
                            Button(action: {
                                addTag(tag)
                                inputText = ""
                            }) {
                                TagView(tag: tag)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 2)
                }
            }
        }
    }
    
    private func addTag(_ tag: Tag) {
        if !selectedTags.contains(tag) {
            selectedTags.append(tag)
        }
    }
    
    private func removeTag(_ tag: Tag) {
        selectedTags.removeAll { $0 == tag }
    }
    
    private func createTagFromInput() {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        if let newTag = tagManager.createTag(name: inputText) {
            addTag(newTag)
            inputText = ""
        }
    }
}

struct TagSelectorView: View {
    @Binding var selectedTags: [Tag]
    @ObservedObject var tagManager: TagManager
    @Binding var inputText: String
    
    @State private var showingCreateTag = false
    @State private var newTagName = ""
    @State private var newTagColor = "colorPrimary"
    
    @Environment(\.presentationMode) var presentationMode
    
    var availableTags: [Tag] {
        tagManager.allTags.filter { tag in
            !selectedTags.contains(tag)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if !availableTags.isEmpty {
                    List {
                        ForEach(availableTags, id: \.self) { tag in
                            HStack {
                                TagView(tag: tag)
                                Spacer()
                                Button("Add".localized) {
                                    selectedTags.append(tag)
                                }
                                .foregroundColor(Color.colorPrimary)
                            }
                            .listRowBackground(Color.clear)
                        }
                    }
                    .listStyle(PlainListStyle())
                } else {
                    Spacer()
                    Text("No available tags".localized)
                        .foregroundColor(.gray)
                    Spacer()
                }
            }
            .navigationTitle("Select Tags".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done".localized) {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("New Tag".localized) {
                        showingCreateTag = true
                    }
                }
            }
            .sheet(isPresented: $showingCreateTag) {
                CreateTagView(tagManager: tagManager)
            }
        }
    }
}

struct CreateTagView: View {
    @ObservedObject var tagManager: TagManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var tagName = ""
    @State private var selectedColor = "colorPrimary"
    
    var body: some View {
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
                
                Spacer()
            }
            .padding()
            .navigationTitle("Create Tag".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel".localized) {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create".localized) {
                        createTag()
                    }
                    .disabled(tagName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private func createTag() {
        if tagManager.createTag(name: tagName, color: selectedColor) != nil {
            presentationMode.wrappedValue.dismiss()
        }
    }
}