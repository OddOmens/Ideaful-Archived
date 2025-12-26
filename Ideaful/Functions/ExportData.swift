import SwiftUI
import Foundation
import CoreData

class ExportManager {
    static func exportIdeas(context: NSManagedObjectContext, format: ExportFormat) -> [URL] {
        // Fetch ideas from CoreData
        let fetchRequest: NSFetchRequest<Idea> = Idea.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "updateDate", ascending: true)]
        
        do {
            let ideas = try context.fetch(fetchRequest)
            let groupedIdeas = Dictionary(grouping: ideas, by: { $0.status ?? "Unassigned" })
            
            switch format {
            case .text:
                let textFileURL = createTextFile(ideas: groupedIdeas)
                return [textFileURL]
            case .markdown:
                let markdownFileURL = createMarkdownFile(ideas: groupedIdeas)
                return [markdownFileURL]
            case .csv:
                let csvFileURL = createCSVFile(ideas: groupedIdeas)
                return [csvFileURL]
            }
        } catch {
            print("Failed to fetch ideas: \(error)")
            return []
        }
    }
    
    static func exportSingleIdea(idea: Idea, format: ExportFormat) -> URL? {
        let groupedIdeas = ["Single Idea": [idea]]
        
        switch format {
        case .text:
            return createTextFile(ideas: groupedIdeas)
        case .markdown:
            return createMarkdownFile(ideas: groupedIdeas)
        case .csv:
            return createCSVFile(ideas: groupedIdeas)
        }
    }
    
    private static func createTextFile(ideas: [String: [Idea]]) -> URL {
        var content = ""
        for (status, ideas) in ideas {
            content.append("# \(status)\n")
            for idea in ideas {
                content.append("- \(idea.title ?? ""): \(idea.shortDesc ?? "")\n")
                content.append("  Notes: \(idea.notes ?? "")\n")
            }
            content.append("\n")
        }
        return saveFile(content: content, extension: "txt")
    }
    
    private static func createMarkdownFile(ideas: [String: [Idea]]) -> URL {
        var content = ""
        for (status, ideas) in ideas {
            content.append("# \(status)\n")
            for idea in ideas {
                content.append("- \(idea.title ?? ""): \(idea.shortDesc ?? "")\n")
                content.append("  Notes: \(idea.notes ?? "")\n")
            }
            content.append("\n")
        }
        return saveFile(content: content, extension: "md")
    }
    
    private static func createCSVFile(ideas: [String: [Idea]]) -> URL {
        var content = "Status,Title,ShortDesc,Notes,UpdateDate\n"
        for (status, ideas) in ideas {
            for idea in ideas {
                let updateDate = idea.updateDate ?? Date()
                let dateString = ISO8601DateFormatter().string(from: updateDate)
                content.append("\"\(status)\",\"\(idea.title ?? "")\",\"\(idea.shortDesc ?? "")\",\"\(idea.notes ?? "")\",\"\(dateString)\"\n")
            }
        }
        return saveFile(content: content, extension: "csv")
    }
    
    private static func saveFile(content: String, extension: String) -> URL {
        let fileName = "IdeasExport.\(`extension`)"
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try content.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            print("Failed to save file: \(error)")
            return URL(fileURLWithPath: "")
        }
    }
}

enum ExportFormat {
    case text
    case markdown
    case csv
}

struct ExportOptionsView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var viewContext
    @State private var showShareSheet = false
    @State private var exportURLs: [URL] = []
    @State private var selectedFormat: ExportFormat?
    @State private var isExporting = false
    var idea: Idea?
    
    @EnvironmentObject var themeManager: ThemeManager


    var body: some View {
        VStack {
            VStack {
                Button(action: {
                    selectedFormat = .text
                    exportIdeas(as: .text)
                }) {
                    HStack {
                        Image("file-alt")
                            .resizable()
                            .renderingMode(.template)
                            
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .padding(6)
                        
                        Text("Export as Text File".localized)
                            
                        
                        Spacer()
                    }
                }

                Divider()
                    .padding(.horizontal)
                
                Button(action: {
                    selectedFormat = .csv
                    exportIdeas(as: .csv)
                }) {
                    HStack {
                        Image("file-alt")
                            .resizable()
                            .renderingMode(.template)
                            
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .padding(6)
                        
                        Text("Export as CSV File".localized)
                            
                        
                        Spacer()
                    }
                }
                
                Divider()
                    .padding(.horizontal)
                
                Button(action: {
                    selectedFormat = .markdown
                    exportIdeas(as: .markdown)
                }) {
                    HStack {
                        Image("file-alt")
                            .resizable()
                            .renderingMode(.template)
                            
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .padding(6)
                        
                        Text("Export as Markdown File".localized)
                            
                        
                        Spacer()
                    }
                }
            }
            .padding()
            .sheet(isPresented: $showShareSheet, content: {
                ActivityView(activityItems: exportURLs)
                    .onDisappear {
                        selectedFormat = nil
                        exportURLs = []
                    }
            })
            .overlay(
                Group {
                    if isExporting {
                        ProgressView("Exporting...")
                            .progressViewStyle(CircularProgressViewStyle())
                    }
                }
            )
            
            Spacer()
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(idea != nil ? "Export Idea".localized : "Export All Ideas".localized)
                    .bold()
            }
        }
    }

    private func exportIdeas(as format: ExportFormat) {
        isExporting = true
        DispatchQueue.global(qos: .userInitiated).async {
            var urls: [URL] = []
            if let idea = idea {
                if let url = ExportManager.exportSingleIdea(idea: idea, format: format) {
                    urls.append(url)
                }
            } else {
                urls = ExportManager.exportIdeas(context: viewContext, format: format)
            }
            DispatchQueue.main.async {
                exportURLs = urls
                isExporting = false
                showShareSheet = true
            }
        }
    }
}

// Helper view for presenting the share sheet
struct ActivityView: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityView>) -> UIActivityViewController {
        return UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityView>) {}
}
