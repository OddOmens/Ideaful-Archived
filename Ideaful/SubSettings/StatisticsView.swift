import SwiftUI
import CoreData

struct StatisticsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var themeManager: ThemeManager

    @State private var isLoading = true
    @State private var stats: Stats?
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            Group {
                if isLoading {
                    ProgressView("Loading...")
                } else if let error = errorMessage {
                    Text("Error: \(error)")
                } else if let stats = stats {
                    statisticsList(stats: stats)
                } else {
                    Text("No statistics available")
                }
            }
        }
        .navigationTitle("Statistics".localized)
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
                    Button(action: {
                        loadStatistics()
                    }) {
                        Image("refresh-cw")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(Color.colorPrimary)
                            .scaledToFit()
                            .frame(width: 22, height: 22)
                    }
                }
            }
        }
        .onAppear {
            loadStatistics()
        }
    }

    private func statisticsList(stats: Stats) -> some View {
        List {
            Section(header: Text("Ideas")) {
                StatisticRow(icon: "file-pencil-alt", label: "Ideas Created", value: Int(stats.totalIdeasCreated))
                StatisticRow(icon: "file-check-alt", label: "Ideas Completed", value: Int(stats.totalIdeasCompleted))
                StatisticRow(icon: "file-xmark-alt", label: "Ideas Cancelled", value: Int(stats.totalIdeasCancelled))
                StatisticRow(icon: "file-shredder", label: "Ideas Deleted", value: Int(stats.totalIdeasDeleted))
            }
            
            Section(header: Text("Tasks")) {
                StatisticRow(icon: "file-pencil-alt", label: "Tasks Created", value: Int(stats.totalTasksCreated))
                StatisticRow(icon: "file-check-alt", label: "Tasks Completed", value: Int(stats.totalTasksCompleted))
                StatisticRow(icon: "file-shredder", label: "Tasks Deleted", value: Int(stats.totalTasksDeleted))
            }
            
            Section(header: Text("Notes")) {
                StatisticRow(icon: "file-pencil-alt", label: "Notes Created", value: Int(stats.totalNotesCreated))
                StatisticRow(icon: "file-shredder", label: "Notes Deleted", value: Int(stats.totalNotesDeleted))
            }
        }
        .listStyle(PlainListStyle())
        .scrollContentBackground(.hidden)
        .background(Color.clear)
        .scrollDisabled(true)
    }

    private func loadStatistics() {
        isLoading = true
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let fetchRequest: NSFetchRequest<Stats> = Stats.fetchRequest()
                let results = try viewContext.fetch(fetchRequest)
                
                DispatchQueue.main.async {
                    self.stats = results.first
                    self.isLoading = false
                    self.errorMessage = nil
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                    print("Error loading statistics: \(error)")
                }
            }
        }
    }
}

struct StatisticRow: View {
    var icon: String
    var label: String
    var value: Int
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        HStack {
            Image(icon)
                .resizable()
                .renderingMode(.template)
                .foregroundColor(Color.colorPrimary)
                .scaledToFit()
                .frame(width: 22, height: 22)
            Text(label)
                
            Spacer()
            Text("\(value)")
                .bold()
                
        }
        .padding(.vertical, 5)
        .listRowBackground(Color.clear)
    }
}
