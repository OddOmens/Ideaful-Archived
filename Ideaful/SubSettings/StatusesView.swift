import SwiftUI
import CoreData
import Combine

struct Status: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let canBeDisabled: Bool
    
    var color: Color {
        GlobalConstants.statusColors[name] ?? .gray
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Status, rhs: Status) -> Bool {
        lhs.id == rhs.id
    }
}

class StatusManager: ObservableObject {
    @Published var enabledStatuses: Set<Status>
    @Published var useBlackForeground: Bool
    let allStatuses: [Status]
    private let viewContext: NSManagedObjectContext
    
    static let shared = StatusManager(viewContext: PersistenceController.shared.container.viewContext)
    
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
        self.allStatuses = GlobalConstants.orderedStatuses.map { statusName in
            Status(name: statusName, canBeDisabled: statusName != "Unassigned")
        }
        
        if let savedStatusNames = UserDefaults.standard.array(forKey: "enabledStatuses") as? [String] {
            self.enabledStatuses = Set(allStatuses.filter { savedStatusNames.contains($0.name) })
        } else {
            self.enabledStatuses = Set(allStatuses.filter { !$0.canBeDisabled || ["Unassigned", "New Idea", "Ideation", "Not Started", "Started", "Researching", "Planning", "Developing", "Prototyping", "Testing", "Troubleshooting", "Reviewing", "Deferred", "Blocked", "Maintenance", "Quality Control", "Awaiting Feedback", "Awaiting Resources", "Pre-Production", "Production", "Post-Production", "On Hold", "Documentation", "Marketing", "Pitching", "Seeking Funding", "Funded", "Validated", "Under Review", "Sunsetting", "Released", "Completed", "Cancelled", "Abandoned", "Archived"].contains($0.name) })
        }
        
        self.useBlackForeground = UserDefaults.standard.bool(forKey: "useBlackForeground")
        
        // Force enable statuses that are in use
        for status in allStatuses {
            if isStatusInUse(status.name) {
                enabledStatuses.insert(status)
            }
        }
    }
    
    func toggleStatus(_ status: Status, isEnabled: Bool) {
        if isEnabled {
            enabledStatuses.insert(status)
        } else if status.canBeDisabled && !isStatusInUse(status.name) {
            enabledStatuses.remove(status)
        } else if isStatusInUse(status.name) {
            // Show notification that status can't be disabled
            ToastNotificationViewModel.shared.showNotification(
                message: "Cannot disable '\(status.name)' status as it's currently in use.",
                icon: "PreviewAppIcon"
            )
        }
        saveStatuses()
    }
    
    func isStatusInUse(_ status: String) -> Bool {
        let fetchRequest: NSFetchRequest<Idea> = Idea.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "status == %@", status)
        fetchRequest.fetchLimit = 1
        
        do {
            let count = try viewContext.count(for: fetchRequest)
            return count > 0
        } catch {
            print("Error checking if status is in use: \(error)")
            return false
        }
    }
    
    func toggleForegroundColor(_ isBlack: Bool) {
        useBlackForeground = isBlack
        UserDefaults.standard.set(isBlack, forKey: "useBlackForeground")
    }
    
    private func saveStatuses() {
        let enabledStatusNames = enabledStatuses.map { $0.name }
        UserDefaults.standard.set(enabledStatusNames, forKey: "enabledStatuses")
    }
    
    func canDisableStatus(_ status: Status) -> Bool {
        return status.canBeDisabled && !isStatusInUse(status.name)
    }
}

struct StatusesView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var statusManager: StatusManager
    
    init() {
        _statusManager = StateObject(wrappedValue: StatusManager.shared)
    }
    
    var body: some View {
        VStack {
            Toggle("High Contrast Text", isOn: Binding(
                get: { statusManager.useBlackForeground },
                set: { statusManager.toggleForegroundColor($0) }
            ))
        }.padding()
        
        Divider().padding(.horizontal)
        
        List {
            ForEach(statusManager.allStatuses) { status in
                StatusToggleRow(
                    status: status,
                    isEnabled: statusManager.enabledStatuses.contains(status),
                    onToggle: { isEnabled in
                        statusManager.toggleStatus(status, isEnabled: isEnabled)
                    }
                )
            }
        }
        .listStyle(.inset)
        .navigationTitle("Statuses")
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
        }
    }
}

struct StatusToggleRow: View {
    let status: Status
    let isEnabled: Bool
    let onToggle: (Bool) -> Void
    @ObservedObject private var statusManager = StatusManager.shared
    
    var body: some View {
        HStack {
            StatusLabel(name: status.name, color: status.color)
            Spacer()
            if status.canBeDisabled {
                Toggle("", isOn: Binding(
                    get: { isEnabled },
                    set: { newValue in
                        if newValue || statusManager.canDisableStatus(status) {
                            onToggle(newValue)
                        }
                    }
                ))
                .disabled(statusManager.isStatusInUse(status.name))
            } else {
                Image(systemName: "lock.fill")
                    .foregroundColor(.gray)
            }
        }
    }
}

struct StatusLabel: View {
    let name: String
    let color: Color
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject private var statusManager = StatusManager.shared

    var body: some View {
        Text(GlobalConstants.localizedStatus(name))
            .font(.system(size: 14, weight: .medium))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                ZStack {
                    Color.black.opacity(colorScheme == .dark ? 0.0 : 0.05)
                    color.opacity(0.35)
                }
            )
            .foregroundColor(statusManager.useBlackForeground ? Color.colorPrimary : color)
            .clipShape(Capsule())
    }
}

struct StatusSelectorView: View {
    @Binding var selectedStatus: String
    @ObservedObject private var statusManager = StatusManager.shared
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        List {
            ForEach(GlobalConstants.orderedStatuses, id: \.self) { statusName in
                if let status = statusManager.enabledStatuses.first(where: { $0.name == statusName }) {
                    Button(action: {
                        selectedStatus = status.name
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            StatusLabel(name: status.name, color: status.color)
                            Spacer()
                            if selectedStatus == status.name {
                                Image("check")
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
        .listStyle(.inset)
        .navigationTitle("Select Status")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
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
    }
}
