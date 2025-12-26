import SwiftUI
import Foundation
import CoreData

class ImportManager {
    static func importIdeas(from url: URL, format: ImportFormat, context: NSManagedObjectContext) {
        switch format {
        case .text, .markdown:
            importTextOrMarkdownFile(url: url, context: context)
        }
    }

    private static func importTextOrMarkdownFile(url: URL, context: NSManagedObjectContext) {
        do {
            let content = try String(contentsOf: url, encoding: .utf8)
            let lines = content.split(separator: "\n")
            var currentStatus: String?
            var currentTitle: String?
            var currentShortDesc: String?
            var currentNotes: String?
            
            for line in lines {
                if line.starts(with: "# ") {
                    currentStatus = String(line.dropFirst(2))
                } else if line.starts(with: "- ") {
                    let ideaComponents = line.dropFirst(2).split(separator: ":", maxSplits: 2)
                    if ideaComponents.count == 3 {
                        currentTitle = String(ideaComponents[0]).trimmingCharacters(in: .whitespaces)
                        currentShortDesc = String(ideaComponents[1]).trimmingCharacters(in: .whitespaces)
                        currentNotes = String(ideaComponents[2]).trimmingCharacters(in: .whitespaces)
                        if let title = currentTitle, let shortDesc = currentShortDesc, let notes = currentNotes {
                            createIdea(title: title, shortDesc: shortDesc, notes: notes, status: currentStatus, context: context)
                        }
                    }
                }
            }
        } catch {
            print("Failed to read file: \(error)")
        }
    }

    private static func createIdea(title: String, shortDesc: String, notes: String, status: String?, context: NSManagedObjectContext) {
        let idea = Idea(context: context)
        idea.title = title
        idea.shortDesc = shortDesc
        idea.notes = notes
        idea.status = status
        idea.updateDate = Date()
        saveContext(context: context)
    }

    private static func saveContext(context: NSManagedObjectContext) {
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
}

enum ImportFormat {
    case text
    case markdown
}

struct ImportOptionsView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var viewContext
    @EnvironmentObject var themeManager: ThemeManager

    
    @State private var showFilePicker = false
    @State private var selectedURL: URL?
    @State private var selectedFormat: ImportFormat?
    @State private var isImporting = false

    var body: some View {
        VStack {
            VStack(spacing: 0) {
                Text("Import Ideas")
                    .font(.system(size: 16))
                    .bold()
                    .foregroundColor(Color.colorPrimary)
            }
            .frame(maxWidth: .infinity)
            

            .padding()
            
            VStack {
                Button(action: {
                    selectedFormat = .text
                    showFilePicker = true
                }) {
                    HStack {
                        Image(systemName: "doc.text")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(Color.colorPrimary)
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .padding(6)
                            .cornerRadius(80)
                        
                        Text("Import from Text File")
                        
                        Spacer()
                    }
                }

                Divider().padding(.horizontal)
                
                Button(action: {
                    selectedFormat = .markdown
                    showFilePicker = true
                }) {
                    HStack {
                        Image(systemName: "doc.text")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(Color.colorPrimary)
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .padding(6)
                            .cornerRadius(80)
                        
                        Text("Import from Markdown File")
                        
                        Spacer()
                    }
                }
            }
            .padding()
            .sheet(isPresented: $showFilePicker, content: {
                DocumentPickerView(url: $selectedURL, allowedTypes: ["public.text", "public.plain-text", "public.markdown"])
                    .onDisappear {
                        if let url = selectedURL, let format = selectedFormat {
                            importIdeas(from: url, as: format)
                        }
                    }
            })
            .overlay(
                Group {
                    if isImporting {
                        ProgressView("Importing...")
                            .progressViewStyle(CircularProgressViewStyle())
                    }
                }
            )
            
            Spacer()
        }
    }

    private func importIdeas(from url: URL, as format: ImportFormat) {
        isImporting = true
        DispatchQueue.global(qos: .userInitiated).async {
            ImportManager.importIdeas(from: url, format: format, context: viewContext)
            DispatchQueue.main.async {
                isImporting = false
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

struct DocumentPickerView: UIViewControllerRepresentable {
    @Binding var url: URL?
    var allowedTypes: [String]

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let controller = UIDocumentPickerViewController(documentTypes: allowedTypes, in: .import)
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: DocumentPickerView

        init(_ parent: DocumentPickerView) {
            self.parent = parent
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            parent.url = urls.first
        }
    }
}
